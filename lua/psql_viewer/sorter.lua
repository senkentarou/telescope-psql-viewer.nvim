local sorters = require("telescope.sorters")
local config = require("psql_viewer.config")
local utilities = require("psql_viewer.utilities")

local M = {}

-- Calculate match score based on priority
local function calculate_match_score(prompt, entry)
	local lower_prompt = prompt:lower()
	local ordinal = entry.ordinal
	local display = entry.value.display:lower()
	local table_name = entry.table_name:lower()
	local column_name = entry.column_name:lower()

	-- Check if prompt matches anywhere in ordinal
	if not ordinal:lower():find(lower_prompt, 1, true) then
		return -1
	end

	-- Calculate score based on match position and priority
	if display == lower_prompt then
		return config.SCORE_PRIORITIES.EXACT_MATCH
	elseif display:find("^" .. utilities.escape_pattern(lower_prompt)) then
		return config.SCORE_PRIORITIES.DISPLAY_START
	elseif table_name == lower_prompt then
		return config.SCORE_PRIORITIES.TABLE_EXACT
	elseif table_name:find("^" .. lower_prompt) then
		return config.SCORE_PRIORITIES.TABLE_START
	elseif table_name:find(lower_prompt, 1, true) then
		local pos = table_name:find(lower_prompt, 1, true)
		return config.SCORE_PRIORITIES.TABLE_CONTAINS + pos
	elseif column_name:find("^" .. lower_prompt) then
		return config.SCORE_PRIORITIES.COLUMN_START
	elseif column_name:find(lower_prompt, 1, true) then
		local pos = column_name:find(lower_prompt, 1, true)
		return config.SCORE_PRIORITIES.COLUMN_CONTAINS + pos
	else
		local pos = ordinal:lower():find(lower_prompt, 1, true)
		return config.SCORE_PRIORITIES.OTHER + (pos or 0)
	end
end

-- Create highlight ranges for matched text
local function create_highlight_ranges(prompt, display)
	local highlights = {}
	local display_str = type(display) == "string" and display or tostring(display)
	local lower_display = display_str:lower()
	local lower_prompt = prompt:lower()

	-- Find all occurrences of the prompt
	local start_pos = 1
	while start_pos <= #display_str do
		local pos = lower_display:find(lower_prompt, start_pos, true)
		if not pos then
			break
		end

		table.insert(highlights, { start = pos - 1, finish = pos + #prompt - 1 })
		start_pos = pos + 1
	end

	return highlights
end

-- Custom sorter that preserves table>column order
function M.create_table_column_sorter()
	return sorters.new({
		discard = true,
		scoring_function = function(_, prompt, _, entry)
			if not prompt or prompt == "" then
				return 1
			end

			if type(entry.ordinal) ~= "string" then
				return -1
			end

			return calculate_match_score(prompt, entry)
		end,
		highlighter = function(_, prompt, display)
			if not prompt or prompt == "" then
				return {}
			end

			return create_highlight_ranges(prompt, display)
		end,
	})
end

return M
