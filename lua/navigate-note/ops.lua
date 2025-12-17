--[[
This is a vim plugin.

When we enter a file named `nav.md`, it will switch into nav-mode in the buffer.
You will navigate to the next `file:line` pattern in the `nav.md` when I press <tab>.
When I press <m-cr> when I'm on `file:line`, enter the according file and line.
It will leave the nav-mode if I leave the buffer.

When I'm not in nav-mode, `<localleader>na` will add a new line `file:line` (i.e. the position of current file) into the file `nav.md`.

`<m-h>` will open the `nav.md`. Then use `<m-p>` to add the position you are just from into the `nav.md`. (It is the more commanded way to add link into files)

Here is an example of `nav.md`
```markdown
- [[start.sh:30]\]:  the entrance of the project
- [[src/utils.py:40]\]: important utils
```


TODOs:
- [x] Append to next line
- [x] Always use relative path
]]
local conf = require("navigate-note.conf")
local options = conf.options
local utils = require("navigate-note.utils")

local M = {
  last_entry = "",
  active_keymap = {},
  mode = {
    jump = "file", -- Options: "file" or "line"
  },
}
local mode_display_map = {
  file = "📋",
  line = "🎯",
}

local api = vim.api
local nav_md_file = options.filename

-- Function to return all {line_number, start_pos, end_pos}  
-- If enable_block is true, only return matches in the block where the cursor is (block delimited by ^---$ or ^***$)
local function get_all_matched(content, enable_block)
  if content == nil then
    content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  end

  enable_block = enable_block or false
  local matches = {}
  local lines = {}
  for line in content:gmatch("([^\r\n]*)\r?\n?") do
    table.insert(lines, line)
  end

  local range_start, range_end = 1, #lines
  if enable_block then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]

    -- Block delimiters: exactly '---' or '***'
    local top_sep = 0
    for i = cursor_line - 1, 1, -1 do
      if lines[i]:match("^%-%-%-+$") or lines[i]:match("^%*%*%*+$") then
        top_sep = i
        break
      end
    end

    local bot_sep = #lines + 1
    for i = cursor_line + 1, #lines do
      if lines[i]:match("^%-%-%-+$") or lines[i]:match("^%*%*%*+$") then
        bot_sep = i
        break
      end
    end

    range_start = top_sep + 1
    range_end = bot_sep - 1
  end

  for i = range_start, range_end do
    local line = lines[i]
    local start_pos, end_pos = 0, 0
    while true do
      start_pos, end_pos = string.find(line, conf.link_patterns.file_line_pattern, end_pos + 1)
      if not start_pos then
        break
      end
      table.insert(matches, { i, start_pos - 1, end_pos - 1 })
    end
  end

  return matches
end

local opened_windows = {}

---
---@param contents table List of lines to be displayed in the hover window
---@param filetype string The file type to be set for the hover window buffer
---@param duration number Duration in milliseconds for which the hover window will be displayed
---@param hl_linenbr number Line number to be highlighted in the hover window (1-based)
local function create_hover_window(contents, filetype, duration, hl_linenbr)
  -- Close previously opened windows
  for _, win in ipairs(opened_windows) do
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end
  opened_windows = {}

  duration = duration or 3000

  local buf = api.nvim_create_buf(false, true)
  -- Set the file type of the buffer
  api.nvim_buf_set_lines(buf, 0, -1, false, contents)
  api.nvim_set_option_value("filetype", filetype, { buf = buf })
  api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Highlight the line `hl_linenbr` if provided
  if hl_linenbr then
    api.nvim_buf_add_highlight(buf, -1, "Visual", hl_linenbr - 1, 0, -1)
  end

  -- Calculate the width and height of the floating window
  local width
  if type(options.width) == "number" then
    if options.width < 1 then
      width = math.floor(vim.api.nvim_win_get_width(0) * options.width)
    else
      width = options.width
    end
  else
    width = 120
  end
  local height = math.max(#contents, 1)

  -- Calculate the position of the floating window relative to the cursor
  local opts = {
    relative = "cursor", -- Position relative to the cursor
    row = 1 - hl_linenbr, -- Align the box just below the cursor
    col = 1000, -- make the window aligh to the right (seems Neovim will make sure it is visible)
    width = width,
    height = height,
    style = "minimal",
    anchor = "NW", -- Align the box to the top-left corner of the calculated position
  }

  -- Create the floating window
  local current_hover_win = api.nvim_open_win(buf, false, opts)
  api.nvim_set_option_value("wrap", false, { win = current_hover_win })
  table.insert(opened_windows, current_hover_win)

  -- Set up a timer to close the window after the specified duration
  vim.defer_fn(function()
    if api.nvim_win_is_valid(current_hover_win) then
      api.nvim_win_close(current_hover_win, true)
    end
  end, duration)
end

local function get_content(file, line, context_line_count)
  if vim.fn.filereadable(file) == 0 then
    return nil -- Return nil if the file does not exist
  end

  -- Open the file in a new buffer
  local file_bufnr = vim.fn.bufnr(file, true)
  if file_bufnr == -1 then
    file_bufnr = vim.fn.bufadd(file)
  end
  vim.fn.bufload(file_bufnr)

  if line == "" or line == nil then
    -- TODO: set the line to the position last time we close it
    line = 1
  end

  -- Force filetype detection and trigger BufRead autocmds for proper file detection
  vim.api.nvim_exec_autocmds('BufRead', { buffer = file_bufnr })

  -- Get the context of the file and line
  local context_lines = vim.api.nvim_buf_get_lines(
    file_bufnr,
    math.max(0, tonumber(line) - context_line_count),
    tonumber(line) + context_line_count - 1,
    false
  )
  -- NOTE: we need to delay for a while to load the buffer. otherwise, options will be missing
  -- require"snacks".debug(file, file_bufnr, vim.bo[file_bufnr].filetype)
  return context_lines, file_bufnr
end

local function goto_cursor(bufnr, match_item)
  local context_line_count = options.context_line_count.tab
  local row, col = match_item[1], match_item[2]
  api.nvim_win_set_cursor(bufnr, { row, col })

  -- Extract the file path and line number from the match_item
  local current_line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  if not utils.is_tmux(current_line) then -- Use the new is_tmux function
    local file, line_or_tmux = string.match(current_line, conf.link_patterns.file_line_pattern)
    -- Create a hover window to show the context of the file and line
    local line = line_or_tmux
    if line and not line:match("^%d*$") then
      line = nil
    end
    local context_lines, file_bufnr = get_content(file, line, context_line_count)
    if context_lines ~= nil then
      create_hover_window(
        context_lines,
        vim.bo[file_bufnr].filetype,
        3000,
        math.max(1, #context_lines - context_line_count + 1)
      )
    end
  end
end

local function navigate_to_next(reverse)
  local cursor_pos = api.nvim_win_get_cursor(0)

  -- Get all matches in the current buffer
  local buffer_content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local matches = get_all_matched(buffer_content)
  if #matches == 0 then
    print("No file:line patterns found")
    return
  end

  local found = false
  if reverse then
    -- Find the previous match
    for i = #matches, 1, -1 do
      local match = matches[i]
      if match[1] < cursor_pos[1] or match[1] == cursor_pos[1] and cursor_pos[2] > match[3] then
        goto_cursor(0, match)
        found = true
        break
      end
    end

    if not found then
      goto_cursor(0, matches[#matches])
    end
  else
    -- Find the next match
    for _, match in ipairs(matches) do
      if match[1] > cursor_pos[1] or match[1] == cursor_pos[1] and cursor_pos[2] < match[2] then
        goto_cursor(0, match)
        found = true
        break
      end
    end

    if not found then
      goto_cursor(0, matches[1])
    end
  end
end

local function navigate_to_prev()
  navigate_to_next(true)
end

-- Function to open the file and line under cursor
local function open_file_line()
  local current_line = api.nvim_get_current_line()
  local file, line_or_tmux = string.match(current_line, conf.link_patterns.file_line_pattern)
  if file then
    if utils.is_tmux(current_line) then -- Use the new is_tmux function
      -- This is a tmux link
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
    else
      -- This is a file link
      local line = line_or_tmux
      utils.backward() --- it is the key to popup the `nav_md_file` from the jumplist
      api.nvim_command("edit " .. file)
      if M.mode.jump == "line" and line and line:match("^%d+$") then
        api.nvim_win_set_cursor(0, { tonumber(line), 0 })
      else
        print("Opened file: " .. file .. " (no specific line number provided)")
      end
    end
  else
    print("No valid file:line pattern under cursor")
  end
end
local function get_entry()
  -- Force to use relative path
  local file_path = vim.fn.expand("%")
  local relative_path = vim.fn.fnamemodify(file_path, ":.")
  return string.format(conf.link_patterns.entry_format, relative_path, vim.fn.line("."))
end

local function write_entry(entry)
  if entry == nil then
    entry = M.last_entry
  end
  -- Open nav.md and append the new entry
  local buf_exists = false
  local cur_buf = vim.api.nvim_get_current_buf()
  local cur_buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(cur_buf), ":p")
  local nav_md_full_path = vim.fn.fnamemodify(nav_md_file, ":p")

  if cur_buf_name == nav_md_full_path then
    -- If the current buffer is nav.md, append the entry at the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(cur_buf, cursor_pos[1], cursor_pos[1], false, { entry })
    print("Added entry to nav.md buffer at cursor position: " .. entry)
  else
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")
      if buf_name == nav_md_full_path then
        buf_exists = true
        break
      end
    end

    if buf_exists then
      -- If nav.md is already open in a buffer, update the buffer
      local bufnr = vim.fn.bufnr(nav_md_file)
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { entry })
      print("Added entry to nav.md buffer: " .. entry)
    else
      -- Otherwise, append to the file
      local f = io.open(nav_md_file, "a")
      if f then
        f:write(entry .. "\n")
        f:close()
        print("Added entry to nav.md: " .. entry)
      else
        print("Failed to open nav.md")
      end
    end
  end
end

-- Function to add a new file:line entry to nav.md
function M.add_file_line()
  local entry = get_entry()
  write_entry(entry)
end

-- Function to open nav.md
function M.switch_nav_md()
  M.last_entry = get_entry()
  if vim.fn.expand("%:t") == "nav.md" then
    -- If we are already in nav.md, go to the previous file by pressing "<C-^>"
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-^>", true, false, true), "n", true)

    -- make sure jumping into `nav_md_file` does affect `C-^`
    utils.backward() -- use backword to revert the jumplist
    local cur_buf = vim.api.nvim_get_current_buf()
    utils.backward()
    if cur_buf ~= vim.api.nvim_get_current_buf() then
      utils.forward()
    end
  else
    vim.cmd("edit " .. nav_md_file)

    -- Maybe nofile buffer will have advantage.. But I'm not sure
    -- local buf = vim.api.nvim_create_buf(false, true)
    -- -- Set buffer options to make it a scratch buffer
    -- vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    -- vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    -- vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    -- vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    -- -- Open the buffer in a new window
    -- vim.api.nvim_set_current_buf(buf)
    -- vim.cmd("0r " .. nav_md_file)  -- Read the content of nav.md into the buffer
  end
end

local function onetime_keymap(key, func, callback)
  local function _func()
    vim.keymap.del("n", key, { noremap = true, silent = true, buffer = true })
    M.active_keymap[key] = nil
    func()
    if callback ~= nil then
      callback()
    end
  end
  vim.keymap.set("n", key, _func, { noremap = true, silent = true, buffer = true })
  M.active_keymap[key] = _func
end
local function render_winbar_text()
  local mode_text = mode_display_map[M.mode.jump]
  -- render all keymap in conf.keymap.nav_mode
  -- only include active keymap in active_keymap and persistent key map
  local title = "🎹:"

  -- Include persistent keymaps
  for name, key in pairs(options.keymaps["nav_mode"]) do
    if not conf.is_tmp_keymap(name) then
      title = title .. string.format(" (%%#WinbarShortcutsKey#%s%%#WinbarShortcutsName#)%s", key, name)
    end
  end

  -- Include active temporary keymaps
  for name, key in pairs(options.keymaps["nav_mode"]) do
    if conf.is_tmp_keymap(name) then
      for a_key, _ in pairs(M.active_keymap) do
        if a_key == key then
          title = title .. string.format(" (%%#WinbarShortcutsKey#%s%%#WinbarShortcutsName#)%s", key, name)
        end
      end
    end
  end

  return mode_text .. "|" .. title
end

-- Add the following highlight groups in your Neovim configuration to customize the appearance
vim.cmd([[
  highlight link WinbarShortcutsKey Function
  highlight link WinbarShortcutsName Comment
]])

local update_winbar_text = function()
  vim.api.nvim_set_option_value("winbar", render_winbar_text(), { win = vim.api.nvim_get_current_win() })
end

local function open_ith_link(i)
  local matches = get_all_matched(nil, conf.options.enable_block)
  if #matches < i then
    print("No such link")
    return
  end
  local match = matches[i]
  api.nvim_win_set_cursor(0, { match[1], match[2] })
  open_file_line()
end

local NAV_LINK_NS = vim.api.nvim_create_namespace("NavigationLink")
local NAV_LINK_VLINES_NS = vim.api.nvim_create_namespace("NAVVirtualLines")

local function update_virtual_lines(bufnr, matches)
  vim.api.nvim_buf_clear_namespace(bufnr, NAV_LINK_VLINES_NS, 0, -1)
  local context_line_count = options.context_line_count.vline

  if context_line_count > 0 then
    for _, match in ipairs(matches) do
      local row, col = match[1], match[2]
      local current_line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
      if not utils.is_tmux(current_line) then -- Use the new is_tmux function
        local file, line_or_tmux = string.match(current_line, conf.link_patterns.file_line_pattern)
        local line = line_or_tmux
        if line and not line:match("^%d*$") then
          line = nil
        end
        local context_lines = get_content(file, line, context_line_count)
        -- Create a namespace for your extmarks

        if context_lines ~= nil then
          -- Define the virtual lines you want to add
          local virt_lines = {}
          local left_sign
          for i, line_str in ipairs(context_lines) do
            if i == #context_lines then
              left_sign = "└"
            elseif i == #context_lines - context_line_count + 1 then
              left_sign = "├"
            else
              left_sign = "│"
            end
            table.insert(virt_lines, { { string.rep(" ", col) .. left_sign .. line_str, "Comment" } })
          end

          -- Set the extmark with virtual lines
          vim.api.nvim_buf_set_extmark(bufnr, NAV_LINK_VLINES_NS, row, 0, {
            virt_lines = virt_lines,
            virt_lines_above = true, -- Place the virtual lines above the specified line
          })
        end
      end
    end
  end
end

local first_call = true

local function update_extmark(callback_args)
  -- 1) add vritual marks/anchors for the matches
  -- Clear previous extmarks before setting the new extmarks
  local bufnr
  if callback_args ~= nil then
    bufnr = callback_args.buf
  else
    bufnr = vim.api.nvim_get_current_buf()
  end

  vim.api.nvim_buf_clear_namespace(bufnr, NAV_LINK_NS, 0, -1)

  local matches = get_all_matched(nil, conf.options.enable_block)
  for i, match in ipairs(matches) do
    if i > 9 then
      break
    end
    vim.api.nvim_buf_set_extmark(bufnr, NAV_LINK_NS, match[1] - 1, match[3] + 1, {
      virt_text = { { string.format("%s[%d]", mode_display_map[M.mode.jump], i), "Comment" } },
      virt_text_pos = "inline",
    })
  end

  -- 2) read the content in the file and show 5 lines around the link
  -- TODO: if it is first time call the function, wait 1 second. Otherwise, call it immediately

  if first_call then
    first_call = false
    vim.defer_fn(function()
      update_virtual_lines(bufnr, matches)
    end, 300) -- Delay by 1000 milliseconds (1 second)
  else
    update_virtual_lines(bufnr, matches)
  end
end

local match_id = nil -- Variable to store the match ID

local function jump_mode_toggle(mode)
  -- TODO: it does not work when work with  `render-markdown.nvim` when concealing is enabled
  if mode == nil and M.mode.jump == "file" or mode == "line" then
    M.mode.jump = "line"
    -- Delete the matchadd when toggling to "line" mode
    if match_id then
      vim.fn.matchdelete(match_id)
      match_id = nil
    end
  else
    M.mode.jump = "file"
    -- Add `:40` in [[src/utils.py:40]] to @comment highlight group in nav_mode
    -- Just highlight the line number, do not highlight the file path
    -- Use zero-width assertion to make the match more exact
    match_id = vim.fn.matchadd("Comment", conf.link_patterns.match_add, 100)
  end
  update_winbar_text()
  update_extmark()
end

-- Function to enter nav-mode
local function enter_nav_mode()
  print("Enter nav-mode start")
  vim.keymap.set(
    "n",
    options.keymaps["nav_mode"].next,
    navigate_to_next,
    { noremap = true, silent = true, buffer = true }
  )
  vim.keymap.set(
    "n",
    options.keymaps["nav_mode"].prev,
    navigate_to_prev,
    { noremap = true, silent = true, buffer = true }
  )
  vim.keymap.set(
    "n",
    options.keymaps["nav_mode"].open,
    open_file_line,
    { noremap = true, silent = true, buffer = true }
  )
  vim.keymap.set(
    "n",
    options.keymaps["nav_mode"].jump_mode,
    jump_mode_toggle,
    { noremap = true, silent = true, buffer = true }
  )
  vim.keymap.set(
    "n",
    options.keymaps["nav_mode"].switch_back,
    M.switch_nav_md,
    { noremap = true, silent = true, buffer = true }
  )
  -- vim.api.nvim_set_option_value("wrap", false, { scope = "local" }) -- Disable line wrapping in nav-mode; position calcuation in wrapping mode is not accurate

  if M.last_entry ~= "" then
    onetime_keymap(options.keymaps["nav_mode"].append_link, write_entry, update_winbar_text)
  end
  jump_mode_toggle(M.mode.jump)
  -- toggle will automatically run following updates
  -- update_extmark()
  -- update_winbar_text()

  -- Map 1, 2, 3, ..., 9 to open the i-th link in nav.md
  for i = 1, 9 do
    vim.keymap.set("n", tostring(i), function()
      open_ith_link(i)
    end, { noremap = true, silent = true, buffer = true })
  end
  print("Entered nav-mode")
end

-- Function to leave nav-mode
local function leave_nav_mode()
  print("Left nav-mode")
end

-- Autocommand to enter nav-mode when nav.md is opened
local nav_mode_group = vim.api.nvim_create_augroup("NavMode", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = nav_md_file,
  callback = enter_nav_mode,
  group = nav_mode_group,
})

vim.api.nvim_create_autocmd("BufLeave", {
  pattern = nav_md_file,
  callback = leave_nav_mode,
  group = nav_mode_group,
})
-- Autocommand to update extmarks when content changes
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
  pattern = nav_md_file,
  callback = update_extmark,
  group = nav_mode_group,
})

-- Only update extmarks on CursorMoved(CursorMovedI) if there's no movement for 1 second
if options.enable_block then
  local cursor_timer = nil
  local function debounce_update_extmark(callback_args)
    if cursor_timer and not cursor_timer:is_closing() then
      cursor_timer:stop()
      cursor_timer:close()
    end
    cursor_timer = vim.loop.new_timer()
    cursor_timer:start(500, 0, function()
      vim.schedule(function()
        update_extmark(callback_args)
        if cursor_timer and not cursor_timer:is_closing() then
          cursor_timer:stop()
          cursor_timer:close()
        end
        cursor_timer = nil
      end)
    end)
  end

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = nav_md_file,
    callback = debounce_update_extmark,
    group = nav_mode_group,
  })
end

-- When Neovim is launched with the nav.md file directly (e.g., `nvim nav.md`),
-- the plugin's setup code runs *after* initial buffer events like `BufEnter` or
-- `BufWinEnter` have already fired. This means an autocommand listening for
-- those events won't be triggered for the initial file, creating a race condition.
-- Events like `VimEnter` are also not a reliable solution.
-- To reliably handle this startup case, we must manually check if the current
-- buffer is the nav.md file at the time the plugin loads. If it is, we
-- immediately call enter_nav_mode() to ensure the plugin is activated correctly.
if vim.fn.expand("%:t") == nav_md_file then
  enter_nav_mode()
end

return M
