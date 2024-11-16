local M = {
	options = {},
	defaults = {
		filename = "nav.md",
		width = 0.6,
		keymap = {
			nav_mode = {
				next = "<tab>",
				prev = "<s-tab>",
				open = "<m-cr>",
				switch_back = "<m-h>",
				-- preview = "K",
				_tmp_ = {
					append_link = "<m-p>",  -- past will more align with the meaning
				},
			},
			add = "<localleader>na",
			open_nav = "<m-h>",
		},
	},
}

function M.setup(options)
	options = options or {}
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end

return M
