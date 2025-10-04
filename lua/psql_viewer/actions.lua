local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

local M = {}

-- Copy table.column to clipboard
local function copy_column_name(selection)
	local full_column_name = selection.table_name .. "." .. selection.column_name
	vim.fn.setreg("+", full_column_name)
	vim.notify(string.format("Copied: %s (%s)", full_column_name, selection.data_type), vim.log.levels.INFO)
end

-- Search table.column with live_grep
local function search_with_live_grep(selection)
	local full_column_name = selection.table_name .. "." .. selection.column_name
	vim.notify(string.format("Searching for: %s", full_column_name), vim.log.levels.INFO)
	require("telescope.builtin").live_grep({
		default_text = full_column_name,
	})
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

	-- <C-g>: Search with live_grep
	map({ "i", "n" }, "<C-g>", function()
		actions.close(prompt_bufnr)

		local selection = actions_state.get_selected_entry()
		search_with_live_grep(selection)
	end)

	return true
end

return M
