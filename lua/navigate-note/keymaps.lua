local M = {}
local ops = require"navigate-note.ops"
local options = require"navigate-note.conf".options

function M.setup_main_keymaps()
  -- Key mappings
  vim.keymap.set("n", options.keymaps.add, ops.add_file_line, { noremap = true, silent = true })
  vim.keymap.set("n", options.keymaps.open_nav, ops.switch_nav_md, { noremap = true, silent = true })
end


function M.setup()
  M.setup_main_keymaps()
  -- TODO: if `which-key` is installed
  local ok, which_key = pcall(require, "which-key")
  -- include `which_key.add` to handle scenarios where other plugins are also named `which-key`
  if ok and which_key.add then
    which_key.add({
      -- { "<LocalLeader>?", group = "navigate-note" },
    })
  end
end

return M
