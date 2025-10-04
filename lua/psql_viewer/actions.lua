local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local M = {}

-- Copy table.column to clipboard
local function copy_column_name(selection)
	local full_column_name = selection.table_name .. "." .. selection.column_name
	vim.fn.setreg("+", full_column_name)
	vim.notify(string.format("Copied: %s (%s)", full_column_name, selection.data_type), vim.log.levels.INFO)
end

function M.attach_mappings(prompt_bufnr, map)
	-- <CR>: Copy and close
	actions.select_default:replace(function()
		actions.close(prompt_bufnr)

		local selection = actions_state.get_selected_entry()
		copy_column_name(selection)
	end)

	-- <Tab>: Copy without closing
	map({ "i", "n" }, "<Tab>", function()
		local selection = actions_state.get_selected_entry()
		copy_column_name(selection)
	end)

	return true
end

return M
