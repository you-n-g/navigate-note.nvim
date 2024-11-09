local M = {}


function M.setup_main_mappings()
end


function M.setup()
  M.setup_main_mappings()
  -- TODO: if `which-key` is installed
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.add({
      -- { "<LocalLeader>?", group = "navigate-note" },
    })
  end
end

return M
