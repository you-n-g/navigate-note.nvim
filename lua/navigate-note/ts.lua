--[[
How to compress the location of current cursor to a treesitter path and write function to generate and locate this path?

TODO: we have got no luck when trying it
]]

local ts_utils = require'nvim-treesitter.ts_utils'

-- Function to get the current cursor position
function get_cursor_position()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  return row - 1, col
end

-- Function to generate a treesitter path from the current cursor position
-- The path includes both node type and node text
function generate_treesitter_path()
  local row, col = get_cursor_position()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return nil, "No Treesitter node found at cursor position"
  end

local path = {}
  while node do
    local node_text = vim.treesitter.get_node_text(node, 0)  -- FIXME: do not use full text. Use short version

    local short_text = node_text and node_text:sub(1, 10):gsub("\n", " ") or ""  -- Use a short version of the text
    table.insert(path, 1, node:type() .. ":" .. short_text)
    node = node:parent()
  end

  return table.concat(path, " -> ")
end

-- Function to locate a node based on a treesitter path
function locate_node_by_path(path)
  local root = ts_utils.get_root_for_position(0, 0)
  if not root then
    return nil, "No Treesitter root found"
  end

  local node = root
  local path_parts = vim.split(path, " -> ")
  for _, node_info in ipairs(path_parts) do
    local node_type = node_info:match("^(.-):")
    local found = false
    for child in node:iter_children() do
      if child:type() == node_type then
        node = child
        found = true
        break
      end
    end
    if not found then
      return nil, "Node type not found in path: " .. node_type
    end
  end

  return node
end

-- Example usage
function example_usage()
  local path, err = generate_treesitter_path()
  if not path then
    print("Error generating path:", err)
    return
  end

  print("Generated Treesitter Path:", path)

  local node, err = locate_node_by_path(path)
  if not node then
    print("Error locating node:", err)
    return
  end

  print("Located Node Type:", node:type())
end

return {
  generate_treesitter_path = generate_treesitter_path,
  locate_node_by_path = locate_node_by_path,
  example_usage = example_usage
}
