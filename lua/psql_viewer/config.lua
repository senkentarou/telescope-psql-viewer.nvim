local M = {}

-- Score priorities for sorting (lower = higher priority)
M.SCORE_PRIORITIES = {
	EXACT_MATCH = 0,
	DISPLAY_START = 500,
	TABLE_EXACT = 1000,
	TABLE_START = 1500,
	TABLE_CONTAINS = 2000,
	COLUMN_START = 3000,
	COLUMN_CONTAINS = 4000,
	OTHER = 5000,
}

-- Display configuration
M.DISPLAY_CONFIG = {
	column_width = 70,
	type_width = 30,
	separator = " | ",
}

-- Default PostgreSQL configuration
local default_pg_config = {
	pg_password = "postgres",
	pg_host = "localhost",
	pg_user = "postgres",
	pg_port = "5432",
	pg_db = "postgres",
}

-- User configuration (can be set via setup)
local user_config = {}

-- Get PostgreSQL configuration with priority: env > user_config > default
function M.get_pg_config()
	return {
		pg_password = os.getenv("PGPASSWORD") or user_config.pg_password or default_pg_config.pg_password,
		pg_host = os.getenv("PGHOST") or user_config.pg_host or default_pg_config.pg_host,
		pg_user = os.getenv("PGUSER") or user_config.pg_user or default_pg_config.pg_user,
		pg_port = os.getenv("PGPORT") or user_config.pg_port or default_pg_config.pg_port,
		pg_db = os.getenv("PGDATABASE") or user_config.pg_db or default_pg_config.pg_db,
	}
end

-- Setup function to configure user settings
function M.setup(opts)
	opts = opts or {}

	if opts.database then
		user_config.pg_password = opts.database.password
		user_config.pg_host = opts.database.host
		user_config.pg_user = opts.database.user
		user_config.pg_port = opts.database.port
		user_config.pg_db = opts.database.database
	end

	if opts.display then
		if opts.display.column_width then
			M.DISPLAY_CONFIG.column_width = opts.display.column_width
		end
		if opts.display.type_width then
			M.DISPLAY_CONFIG.type_width = opts.display.type_width
		end
		if opts.display.separator then
			M.DISPLAY_CONFIG.separator = opts.display.separator
		end
	end
end

-- For backward compatibility
M.pg_config = M.get_pg_config()

return M
