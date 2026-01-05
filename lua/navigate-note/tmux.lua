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

local function switch_tmux(session, window)
  if window and window ~= "" then
    pcall(vim.fn.system, { "tmux", "select-window", "-t", session .. ":" .. window })
  end

  local ok, err = pcall(vim.fn.system, { "tmux", "switch-client", "-t", session })
  if not ok then
    vim.notify("Failed to switch tmux session: " .. tostring(err), vim.log.levels.ERROR)
  end
  return ok
end

---
-- Send content to a tmux session and perform a post action.
-- @param content string The text content to send.
-- @param session string The tmux session name.
-- @param window string|nil The tmux window name (optional).
-- @param post_action string|nil The action to perform after sending content.
--   Supported values:
--   - "switch" (default): Switch to the tmux session and window.
--   - "enter": Send an Enter key after the content without switching.
local function send_to_tmux(content, session, window, post_action)
  if content == nil or content == "" then
    return
  end

  post_action = post_action or "switch"

  if session then
    -- In tmux, `send-keys` will send the text to the pane. The trailing `Enter` is to execute the command.
    -- content = content .. "\n"  -- Because we have directly switched to the pane, press `Enter` to execute the is a low effort action.
    local target = session
    if window and window ~= "" then
      target = session .. ":" .. window
    end

    -- Use a list for system() to avoid shell escaping issues and handle multibyte characters better.
    -- Use -- to ensure content starting with - is not interpreted as an option.
    local ok, err = pcall(vim.fn.system, { "tmux", "send-keys", "-t", target, "--", content })
    if ok then
      print("Sent content to tmux session: " .. session)

      if post_action == "switch" then
        switch_tmux(session, window)
      elseif post_action == "enter" then
        pcall(vim.fn.system, { "tmux", "send-keys", "-t", target, "Enter" })
      end
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
  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

function M.switch_to_tmux()
  local current_line = api.nvim_get_current_line()
  local file, line_or_tmux = string.match(current_line, conf.link_patterns.file_line_pattern)
  if file and utils.is_tmux(current_line) then
    local tmux_session = line_or_tmux
    local session, window = string.match(tmux_session, "([^%.]+)%.?(.*)")
    if switch_tmux(session, window) then
      print("Switched to tmux session: " .. tmux_session)
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

M.send_to_tmux = send_to_tmux

return M