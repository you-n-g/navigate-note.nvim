local M = {}
local ops = require"navigate-note.ops"
local options = require"navigate-note.conf".options

function M.setup_main_keymaps()
  -- Key mappings
  vim.keymap.set("n", options.keymap.add, ops.add_file_line, { noremap = true, silent = true })
  vim.keymap.set("n", options.keymap.open_nav, ops.switch_nav_md, { noremap = true, silent = true })
end


function M.setup()
  M.setup_main_keymaps()
  -- TODO: if `which-key` is installed
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.add({
      -- { "<LocalLeader>?", group = "navigate-note" },
    })
  end
end

return M
