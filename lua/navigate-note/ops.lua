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
local conf = require"navigate-note.conf"
local options = conf.options
local utils = require"navigate-note.utils"

local M = {
  last_entry = "",
  active_keymap = {},
}

local api = vim.api
local nav_md_file = options.filename

local file_line_pattern = "%[%[([^:%]]+):?(%d*)%]%]"

-- Function to return all {line_number, start_pos, end_pos} in appearing order
local function get_all_matched(content)
  if content == nil then
    content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  end

  local matches = {}
  local line_number = 1

  -- Iterate through each line, including blank lines
  for line in content:gmatch("([^\r\n]*)\r?\n?") do
    local start_pos, end_pos = 0, 0
    while true do
      start_pos, end_pos = string.find(line, file_line_pattern, end_pos + 1)
      if not start_pos then
        break
      end
      table.insert(matches, { line_number, start_pos - 1, end_pos - 1 }) -- -1 to align with the (0, 1) based pos
    end
    line_number = line_number + 1
  end

  return matches
end

local opened_windows = {}

--- 
---@param contents table list of lines to be displayed in the hover window
---@param filetype string the file type to be set for the hover window buffer
---@param duration number duration in milliseconds for which the hover window will be displayed
---@param hl_linenbr number line number to be highlighted in the hover window (1-based)
local function create_hover_window(contents, filetype, duration, hl_linenbr)
  -- Close previously opened windows
  for _, win in ipairs(opened_windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  opened_windows = {}

  if duration == nil then
    duration = 3000
  end
  -- Get the current cursor position
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local first_line_number_visible =  vim.fn.line('w0')  -- the first line number visiable in the current window

  -- Create a new buffer for the floating window
  local buf = vim.api.nvim_create_buf(false, true)
  -- Set the file type of the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
  vim.api.nvim_set_option_value('filetype', filetype, {buf=buf})
  vim.api.nvim_set_option_value('modifiable', false, {buf=buf})
  -- TODO: highlight the line `hl_linenbr`
  if hl_linenbr ~= nil then
    vim.api.nvim_buf_add_highlight(buf, -1, "Visual", hl_linenbr - 1, 0, -1)
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
  -- Calculate the position of the floating window
  local opts = {
    relative = 'win',  -- Position relative to the current window
    row = row - first_line_number_visible - (hl_linenbr ~= nil and (hl_linenbr - 1)),  -- Align the box to the current line
    col = vim.api.nvim_win_get_width(0),  -- Align the box to the right side of the current window
    width = width,
    height = height,
    style = 'minimal',
    anchor = 'NE',  -- Align the box to the top-left corner of the calculated position
  }
  -- Create the floating window
  local current_hover_win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_set_option_value('wrap', false, {win=current_hover_win})
  table.insert(opened_windows, current_hover_win)
  -- Set up a timer to close the window after the specified duration
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(current_hover_win) then
      vim.api.nvim_win_close(current_hover_win, true)
    end
  end, duration)
end

local function goto_cursor(bufnr, match_item)
  local context_line_count = 3
  local row, col = match_item[1], match_item[2]
  api.nvim_win_set_cursor(bufnr, { row, col })

  -- Extract the file path and line number from the match_item
  local current_line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  local file, line = string.match(current_line, file_line_pattern)
  if file then
    -- Open the file in a new buffer
    local file_bufnr = vim.fn.bufnr(file, true)
    if file_bufnr == -1 then
      file_bufnr = vim.fn.bufadd(file)
    end
    vim.fn.bufload(file_bufnr)

    if line == "" then
      -- TODO: set the line to the position last time we close it
      line = 1
    end

    -- Get the context of the file and line
    local context_lines = vim.api.nvim_buf_get_lines(file_bufnr, math.max(0, tonumber(line) - context_line_count), tonumber(line) + context_line_count - 1, false)
    -- Create a hover window to show the context of the file and line
    create_hover_window(context_lines, vim.bo[file_bufnr].filetype, 3000, math.max(1, #context_lines - 2))
  else
    print("No valid file:line pattern found in match_item")
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
  -- match pattern like `src/utils.py:40` or `src/utils.py`
  local file, line = string.match(current_line, file_line_pattern)
  if file then
    utils.backward() --- it is the key to popup the `nav_md_file` from the jumplist
    api.nvim_command("edit " .. file)
    if line and line ~= "" then
      api.nvim_win_set_cursor(0, { tonumber(line), 0 })
    else
      print("Opened file: " .. file .. " (no specific line number provided)")
    end
  else
    print("No valid file:line pattern under cursor")
  end
end

local function get_entry()
  -- Force to use relative path
  local file_path = vim.fn.expand("%")
  local relative_path = vim.fn.fnamemodify(file_path, ":.")
  return string.format("[[%s:%d]]", relative_path, vim.fn.line("."))
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
    utils.backward()  -- use backword to revert the jumplist
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
  -- render all keymap in conf.keymap.nav_mode
  -- only include active keymap in active_keymap and persistent key map
  local title = "🎹:"

  -- Include persistent keymaps
  for name, key in pairs(options.keymaps["nav_mode"]) do
    if not conf.is_tmp_keymap(name) then
      title = title .. " " .. string.format("(%s)%s", key, name)
    end
  end

  -- Include active temporary keymaps
  for name, key in pairs(options.keymaps["nav_mode"]) do
    if conf.is_tmp_keymap(name) then
      for a_key, _ in pairs(M.active_keymap) do
        if a_key == key then
          title = title .. " " .. string.format("(%s)%s", key, name)
        end
      end
    end
  end

  return title
end

local update_winbar_text = function()
  vim.api.nvim_set_option_value("winbar", render_winbar_text(), { win = vim.api.nvim_get_current_win() })
end

local function open_ith_link(i)
  local matches = get_all_matched()
  if #matches < i then
    print("No such link")
    return
  end
  local match = matches[i]
  api.nvim_win_set_cursor(0, { match[1], match[2] })
  open_file_line()
end

local NAV_LINK_NS = vim.api.nvim_create_namespace('NavigationLink')

local function update_extmark()
  -- Clear previous extmarks before setting the new extmarks
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, NAV_LINK_NS, 0, -1)

  local matches = get_all_matched()
  for i, match in ipairs(matches) do
    if i > 9 then
      break
    end
    vim.api.nvim_buf_set_extmark(bufnr, NAV_LINK_NS, match[1] - 1, match[3] + 1, {
      virt_text = { { string.format("🎹[%d]", i), "Comment" } },
      virt_text_pos = "inline",
    })
  end
end

-- Function to enter nav-mode
local function enter_nav_mode()
  update_extmark()
  vim.keymap.set("n", options.keymaps["nav_mode"].next, navigate_to_next, { noremap = true, silent = true, buffer = true })
  vim.keymap.set("n", options.keymaps["nav_mode"].prev, navigate_to_prev, { noremap = true, silent = true, buffer = true })
  vim.keymap.set("n", options.keymaps["nav_mode"].open, open_file_line, { noremap = true, silent = true, buffer = true })
  vim.keymap.set("n", options.keymaps["nav_mode"].switch_back, M.switch_nav_md, { noremap = true, silent = true, buffer = true })
  vim.api.nvim_set_option_value('wrap', false, { scope = 'local' })  -- Disable line wrapping in nav-mode; position calcuation in wrapping mode is not accurate

  if M.last_entry ~= "" then
    onetime_keymap(options.keymaps["nav_mode"].append_link, write_entry, update_winbar_text)
  end
  update_winbar_text()

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
vim.api.nvim_create_autocmd("BufEnter", {
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
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP"}, {
  pattern = nav_md_file,
  callback = update_extmark,
  group = nav_mode_group,
})

return M
