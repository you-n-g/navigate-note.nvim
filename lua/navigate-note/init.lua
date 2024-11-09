local M = {}


function M.setup(options)
  require"navigate-note.conf".setup(options)
  require"navigate-note.mappings".setup()
end


return M
