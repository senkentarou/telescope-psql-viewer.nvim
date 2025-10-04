local M = {}

-- Escape special pattern characters for Lua pattern matching
function M.escape_pattern(str)
	return str:gsub("([%.%-%+%*%?%[%]%^%$%(%)%%])", "%%%1")
end

-- Format column type with length if applicable
function M.format_column_type(column)
	local type_info = column.type
	if column.length then
		type_info = type_info .. "(" .. column.length .. ")"
	end
	return type_info
end

return M
