local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")

local config = require("psql_viewer.config")
local database = require("psql_viewer.database")
local finder_utils = require("psql_viewer.finders")
local sorter = require("psql_viewer.sorter")
local psql_actions = require("psql_viewer.actions")

local M = {}

function M.psql_viewer(opts)
	opts = opts or {}

	local raw_data, success = database.fetch_schema()
	if not success then
		vim.notify("Failed to fetch PostgreSQL schema: " .. raw_data, vim.log.levels.ERROR)
		return
	end

	local tables = database.parse_schema_data(raw_data)
	local entries = finder_utils.create_entries_from_tables(tables)

	local displayer = entry_display.create({
		separator = config.DISPLAY_CONFIG.separator,
		items = {
			{ width = config.DISPLAY_CONFIG.column_width },
			{ width = config.DISPLAY_CONFIG.type_width },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			entry.display,
			entry.data_type,
			entry.nullable,
		})
	end

	pickers
		.new(opts, {
			prompt_title = "PostgreSQL Schema",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry,
						display = function(tbl_entry)
							return make_display(tbl_entry.value)
						end,
						display_text = entry.display, -- For highlighter
						ordinal = entry.display
							.. " "
							.. entry.table_name
							.. " "
							.. entry.column_name
							.. " "
							.. entry.data_type,
						table_name = entry.table_name,
						column_name = entry.column_name,
						data_type = entry.data_type,
						nullable = entry.nullable,
						default = entry.default,
					}
				end,
			}),
			sorter = sorter.create_table_column_sorter(),
			attach_mappings = psql_actions.attach_mappings,
		})
		:find()
end

return M
