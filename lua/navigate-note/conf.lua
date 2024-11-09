local M = {
  options  = {},
  defaults = {
    
    keymap = {
      nav_mode = {
        next = "<tab>",
        prev = "<s-tab>",
        open = "<m-cr>",
        switch_back = "<m-h>",
        _tmp_ = {
          append_link = "a",
        },
      },
      add = "<localleader>na",
      open_nav = "<m-h>",
    },
  }
}


function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end


return M
