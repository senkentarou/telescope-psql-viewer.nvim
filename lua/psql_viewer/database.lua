local config = require("psql_viewer.config")

local M = {}

-- Parse error messages from psql output
local function parse_error_message(output)
	-- Common PostgreSQL error patterns
	if output:match("could not connect to server") then
		return "PostgreSQL server is not running or unreachable"
	elseif output:match("FATAL:") then
		local fatal_msg = output:match("FATAL:%s*(.-)$") or output:match("FATAL:%s*(.-)\n")
		return "Connection failed: " .. (fatal_msg or "Authentication error")
	elseif output:match("password authentication failed") then
		return "Authentication failed: Invalid username or password"
	elseif output:match("database .* does not exist") then
		local db_name = output:match('database "([^"]+)" does not exist')
		return string.format('Database "%s" does not exist', db_name or config.get_pg_config().pg_db)
	elseif output:match("Connection refused") then
		local pg_config = config.get_pg_config()
		return string.format(
			"Connection refused: PostgreSQL is not accepting connections on %s:%s",
			pg_config.pg_host,
			pg_config.pg_port
		)
	elseif output:match("psql: error:") then
		local error_msg = output:match("psql: error:%s*(.-)$") or output:match("psql: error:%s*(.-)\n")
		return "PostgreSQL error: " .. (error_msg or output)
	else
		return "Failed to connect to PostgreSQL: " .. output
	end
end

-- PostgreSQLからスキーマを取得
function M.fetch_schema()
	local query = [[
    SELECT
      t.table_name,
      c.column_name,
      c.data_type,
      c.character_maximum_length,
      c.is_nullable,
      c.column_default,
      c.ordinal_position
    FROM information_schema.tables t
    JOIN information_schema.columns c
      ON t.table_name = c.table_name
    WHERE t.table_schema = 'public'
    ORDER BY t.table_name, c.ordinal_position;
  ]]

	local pg_config = config.get_pg_config()
	local cmd = string.format(
		"PGPASSWORD=%s psql -h %s -U %s -p %s -d %s -t -A -F'|' -c \"%s\" 2>&1",
		pg_config.pg_password,
		pg_config.pg_host,
		pg_config.pg_user,
		pg_config.pg_port,
		pg_config.pg_db,
		query:gsub("\n", " ")
	)

	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		local error_message = parse_error_message(result)
		return error_message, false
	end

	return result, true
end

-- スキーマデータを整形
function M.parse_schema_data(raw_data)
	local lines = vim.split(raw_data, "\n")
	local tables = {}

	for _, line in ipairs(lines) do
		if line ~= "" and not line:match("^psql:") then
			local parts = vim.split(line, "|", { plain = true })
			if #parts >= 6 then
				local table_name = parts[1]
				local column_name = parts[2]
				local data_type = parts[3]
				local max_length = parts[4]
				local is_nullable = parts[5]
				local default_val = parts[6]

				if not tables[table_name] then
					tables[table_name] = {
						name = table_name,
						columns = {},
					}
				end

				local column_info = {
					name = column_name,
					type = data_type,
					length = max_length ~= "" and max_length or nil,
					nullable = is_nullable == "YES",
					default = default_val ~= "" and default_val or nil,
				}

				table.insert(tables[table_name].columns, column_info)
			end
		end
	end

	return tables
end

return M
