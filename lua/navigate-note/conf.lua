local M = {
	options = {},
	defaults = {
		filename = "nav.md",
		width = 0.6,
		keymaps = {
			nav_mode = {
				next = "<tab>",
				prev = "<s-tab>",
				open = "<m-cr>",
				switch_back = "<m-h>",
				-- tmp keymap
				append_link = "<m-p>", -- past will more align with the meaning

        -- mode switching
        jump_mode = "<m-l>",
			},
			add = "<localleader>na",
			open_nav = "<m-h>",
		},
    context_line_count = {-- it would be total `2 * context_line_count - 1` lines
      tab = 8,
      vline = 2,
    },
	},
}

M.TMP_KEYMAP = { "append_link" } -- this keymap will only work for once

function M.is_tmp_keymap(key)
	for _, v in pairs(M.TMP_KEYMAP) do
		if key == v then
			return true
		end
	end
	return false
end

function M.setup(options)
	options = options or {}
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end

return M
