local M = {}


function M.setup(options)
  require"navigate-note.conf".setup(options)
  require"navigate-note.keymaps".setup()
end


return M
