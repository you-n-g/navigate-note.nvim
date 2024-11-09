local M = {
  options  = {},
  defaults = {
  }
}


function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end


return M
