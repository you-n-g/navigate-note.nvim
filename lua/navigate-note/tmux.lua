local api = vim.api
local utils = require("navigate-note.utils")
local conf = require("navigate-note.conf")

local M = {}

local function get_recent_tmux_line(start_line)
  for i = start_line, 1, -1 do
    local line = api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if utils.is_tmux(line) then
      return line
    end
  end
  return nil
end

local function get_tmux_target(start_line)
  local tmux_line = get_recent_tmux_line(start_line)
  if tmux_line then
    local _, line_or_tmux = string.match(tmux_line, conf.link_patterns.file_line_pattern)
    local tmux_session = line_or_tmux
    local session, window = string.match(tmux_session, "([^%.]+)%.?(.*)")
    return session, window
  end
  return nil, nil
end

local function send_to_tmux(content, session, window)
  if content == nil or content == "" then
    return
  end

  if session then
    -- In tmux, `send-keys` will send the text to the pane. The trailing `Enter` is to execute the command.
    -- content = content .. "\n"  -- Because we have directly switched to the pane, press `Enter` to execute the is a low effort action.
    local tmux_command
    if window and window ~= "" then
      tmux_command = "tmux send-keys -t " .. session .. ":" .. window .. " " .. vim.fn.shellescape(content)
    else
      tmux_command = "tmux send-keys -t " .. session .. " " .. vim.fn.shellescape(content)
    end

    local ok, err = pcall(vim.fn.system, tmux_command)
    if ok then
      print("Sent content to tmux session: " .. session)
      local switch_command
      if window and window ~= "" then
        switch_command = "tmux select-window -t " .. session .. ":" .. window .. " && tmux switch-client -t " .. session
      else
        switch_command = "tmux switch-client -t " .. session
      end
      pcall(vim.fn.system, switch_command)
    else
      vim.notify("Failed to send content to tmux session: " .. tostring(err), vim.log.levels.ERROR)
    end
  else
    print("No tmux target found")
  end
end

function M.send_visual_selection_to_tmux()
  local selection = utils.get_visual_selection()
  local start_pos = utils.get_visual_selection_pos().start
  local start_line = start_pos.row
  local session, window = get_tmux_target(start_line)
  send_to_tmux(selection, session, window)
end

function M.switch_to_tmux()
  local current_line = api.nvim_get_current_line()
  local file, line_or_tmux = string.match(current_line, conf.link_patterns.file_line_pattern)
  if file and utils.is_tmux(current_line) then
    local tmux_session = line_or_tmux
    local session, window = string.match(tmux_session, "([^%.]+)%.?(.*)")
    local tmux_command
    if window and window ~= "" then
      tmux_command = "tmux select-window -t " .. session .. ":" .. window .. " && tmux switch-client -t " .. session
    else
      tmux_command = "tmux switch-client -t " .. session
    end

    local ok, err = pcall(vim.fn.system, tmux_command)
    if ok then
      print("Switched to tmux session: " .. tmux_session)
    else
      vim.notify("Failed to switch tmux session: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

function M.send_current_line_to_tmux()
  local current_line = api.nvim_get_current_line()
  local cursor_pos = api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1]
  local session, window = get_tmux_target(start_line)
  send_to_tmux(current_line, session, window)
end

return M
