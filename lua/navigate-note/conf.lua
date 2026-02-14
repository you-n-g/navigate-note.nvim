local M = {
	options = {},
	defaults = {
		filename = "nav.md", -- The filename of the markdown.
		width = 0.6, -- The width of the popup window when jumping in the file with <tab>.
		keymaps = {
			nav_mode = {
				-- Navigation & Jumping
				next = "<tab>",
				prev = "<s-tab>",
				open = "<m-cr>",
				switch_back = "<m-h>", -- Switch back to the previous file from `nav.md`.
				-- Editing
				append_link = "<m-p>", -- (P)aste will more align with the meaning.
				-- Mode switching
				jump_mode = "<m-l>", -- When we jump to a file, jump to the file only or jump to the exact file:line.
			},
			add = "<localleader>na",
			open_nav = "<m-h>", -- Switch to `nav.md`.
		},
		context_line_count = { -- It would be a total of `2 * context_line_count - 1` lines.
			tab = 8,
			vline = 2,
		},
    link_surround = {
      left = "[[",
      right = "]]"
    },
    enable_block = false, -- enable block navigation; block navigation indicates only the block of the cursor will display the peeking window; mark the block with --- or ***
    default_tmux_target = nil, -- The default tmux target (string or function returning string, e.g., "session.window.pane") when no target is found in the file.
	},
}

M.TMP_KEYMAP = { "append_link" } -- This keymap will only work once.

-- the default link style is [[file:line]], all related patterns are here
M.link_patterns = {
  -- match_add=[=[\v\[\[[^:]+:\zs\d+\ze\]\]]=],  -- for highlight numbers
  match_add=[=[%[%[\v[^:]+:\zs\d+\ze\m%]%]]=],  -- for highlight numbers
  entry_format="[[%s:%d]]", --for adding entry
  file_line_pattern="%[%[([^:%]]+):?([^%]]*)%]%]",  -- for extracting file and line
}

local function update_link_patterns()
  local left = vim.pesc(M.options.link_surround.left)
  local right = vim.pesc(M.options.link_surround.right)
  M.link_patterns = {
    -- Pattern for highlighting numbers in the link
    match_add = left .. [=[\v[^:]+:\zs\d+\ze\m]=] .. right,
    -- Format for adding an entry
    entry_format = string.format("%s%%s:%%d%s", M.options.link_surround.left, M.options.link_surround.right),
    -- Pattern for extracting file and line
    file_line_pattern = left .. "([^:%]]+):?([^%]]*)" .. right,
  }
end

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
  update_link_patterns()
end

return M
