--[[
Thanks to the code from https://github.com/kwkarlwang/bufjump.nvim/blob/master/lua/bufjump.lua
]]
local M = {}

local jumpforward = function(num)
  vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-i>"]])
end

function M.forward()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  -- find the next different buffer
  while j < #jumplist and (curBufNum == targetBufNum or vim.api.nvim_buf_is_valid(targetBufNum) == false) do
    j = j + 1
    targetBufNum = jumplist[j].bufnr
  end
  while j + 1 <= #jumplist and jumplist[j + 1].bufnr == targetBufNum and vim.api.nvim_buf_is_valid(targetBufNum) do
    j = j + 1
  end
  if j <= #jumplist and targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpforward(j - i)
  end
end


local jumpbackward = function(num)
  vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-o>"]])
end

function M.backward()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  -- plus one because of one index
  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  while j > 1 and (curBufNum == targetBufNum or not vim.api.nvim_buf_is_valid(targetBufNum)) do
    j = j - 1
    targetBufNum = jumplist[j].bufnr
  end
  if targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpbackward(i - j)
  end
end

local conf

local function get_conf()
  if not conf then
    conf = require("navigate-note.conf")
  end
  return conf
end

function M.is_tmux(link_string)
  if not link_string then
    return false
  end
  local conf = get_conf()
  local file, _ = string.match(link_string, conf.link_patterns.file_line_pattern)
  return file == "T"
end

function M.get_visual_selection_pos()
  local pos = vim.fn.getpos("v")
  local begin_pos = { row = pos[2], col = pos[3] }
  pos = vim.fn.getpos(".")
  local end_pos = { row = pos[2], col = pos[3] }
  if (begin_pos.row < end_pos.row) or ((begin_pos.row == end_pos.row) and (begin_pos.col <= end_pos.col)) then
    return { start = begin_pos, ["end"] = end_pos }
  else
    return { start = end_pos, ["end"] = begin_pos }
  end
end

function M.get_visual_selection()
  local mode = vim.api.nvim_get_mode().mode
  local range_pos = M.get_visual_selection_pos()
  local start_row, start_col = range_pos.start.row, range_pos.start.col
  local end_row, end_col = range_pos["end"].row, range_pos["end"].col

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  if #lines == 0 then
    return ""
  end

  if mode == "v" then
    local last_line = lines[#lines]
    local char_len = vim.fn.strlen(vim.fn.strcharpart(string.sub(last_line, end_col), 0, 1))
    local end_col_inclusive = end_col + char_len - 1

    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col_inclusive)
    else
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col_inclusive)
    end
  end

  return table.concat(lines, "\n")
end


function M.is_in_block()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local block_start, block_end = nil, nil

  -- Find the start of the block
  for i = cursor_pos[1], 1, -1 do
    if string.match(lines[i], "^```") then
      block_start = i
      break
    end
  end

  if block_start then
    -- Find the end of the block
    for i = cursor_pos[1] + 1, #lines do
      if string.match(lines[i], "^```") then
        block_end = i
        break
      end
    end
  end

  if block_start and block_end then
    return block_start, block_end
  end

  return nil
end

return M
