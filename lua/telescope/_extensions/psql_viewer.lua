local builtin = require("psql_viewer.builtin")
local config = require("psql_viewer.config")

return require("telescope").register_extension({
	setup = function(ext_config, _)
		-- Apply configuration from telescope.setup({ extensions = { psql_viewer = {...} } })
		if ext_config then
			config.setup(ext_config)
		end
	end,
	exports = {
		psql_viewer = builtin.psql_viewer,
	},
})
