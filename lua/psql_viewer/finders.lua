local utilities = require("psql_viewer.utilities")

local M = {}

-- Create telescope entries from parsed table data
function M.create_entries_from_tables(tables)
	local entries = {}

	-- Get sorted table names
	local table_names = {}
	for name, _ in pairs(tables) do
		table.insert(table_names, name)
	end
	table.sort(table_names)

	-- Create entries in sorted order
	for _, table_name in ipairs(table_names) do
		local tbl = tables[table_name]
		for _, column in ipairs(tbl.columns) do
			table.insert(entries, {
				table_name = tbl.name,
				column_name = column.name,
				data_type = utilities.format_column_type(column),
				nullable = column.nullable and "NULL" or "NOT NULL",
				default = column.default or "",
				display = tbl.name .. "." .. column.name,
			})
		end
	end

	return entries
end

return M
