local plugin = require("navigate-note")
local tmux = require("navigate-note.tmux")
local utils = require("navigate-note.utils")

describe("setup", function()
  it("works with default", function()
    assert(plugin.setup() == nil, "Successfully setup!")
  end)
end)

describe("navigation previews", function()
  local dir, buf, first_file, second_file

  before_each(function()
    plugin.setup()
    dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    first_file = dir .. "/first.lua"
    second_file = dir .. "/second.lua"
    vim.fn.writefile({ "first file" }, first_file)
    local lines = {}
    for i = 1, 20 do
      lines[i] = "second file line " .. i
    end
    vim.fn.writefile(lines, second_file)
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, dir .. "/nav.md")
    vim.api.nvim_set_current_buf(buf)
  end)

  after_each(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        vim.api.nvim_win_close(win, true)
      end
    end
    vim.api.nvim_buf_delete(buf, { force = true })
    vim.fn.delete(dir, "rf")
  end)

  local function tab_and_preview(line)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.fn.maparg("<Tab>", "n", false, true).callback()
    local previews = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        previews[#previews + 1] = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
      end
    end
    assert.are.equal(1, #previews)
    assert.are.same({ 1, line:find("[[" .. second_file, 1, true) - 1 }, vim.api.nvim_win_get_cursor(0))
    assert.are.equal("second file line 8", previews[1][1])
    assert.are.equal("second file line 15", previews[1][8])
  end

  it("previews the second file and its line when Tab lands on it", function()
    tab_and_preview("[[" .. first_file .. ":1]] [[" .. second_file .. ":15|second]]")
  end)

  it("previews a file link after a tmux link on the same line", function()
    tab_and_preview("[[tmux://session:window.0|agent]] [[" .. second_file .. ":15|second]]")
  end)
end)

describe("tmux links", function()
  before_each(function()
    plugin.setup()
  end)

  it("recognizes tmux scheme links", function()
    assert.is_true(utils.is_tmux("[[tmux://0-coding-agent:3.0]]"))
  end)

  it("does not recognize old T links", function()
    assert.is_false(utils.is_tmux("[[T:0-coding-agent.orchestrator.0]]"))
  end)

  it("parses tmux target syntax with window index", function()
    local session, window, pane = tmux.parse_tmux_target_string("tmux://0-coding-agent:3.0")

    assert.are.equal("0-coding-agent", session)
    assert.are.equal("3", window)
    assert.are.equal("0", pane)
  end)

  it("parses tmux target syntax with window name", function()
    local session, window, pane = tmux.parse_tmux_target_string("tmux://0-coding-agent:orchestrator.0")

    assert.are.equal("0-coding-agent", session)
    assert.are.equal("orchestrator", window)
    assert.are.equal("0", pane)
  end)

  it("parses the target fragment captured from markdown links", function()
    local session, window, pane = tmux.parse_tmux_target_string("//0-coding-agent:orchestrator.0")

    assert.are.equal("0-coding-agent", session)
    assert.are.equal("orchestrator", window)
    assert.are.equal("0", pane)
  end)

end)

describe("aliased links", function()
  before_each(function()
    plugin.setup()
  end)

  it("opens file and line links without including the alias in the target", function()
    local link = utils.get_link_at_cursor("[[src/main.lua:42|entry point]]")

    assert.are.equal("src/main.lua", link.file)
    assert.are.equal("42", link.target)
  end)

  it("opens file links without a line number", function()
    local link = utils.get_link_at_cursor("[[README.md|documentation]]")

    assert.are.equal("README.md", link.file)
    assert.are.equal("", link.target)
  end)

  it("recognizes aliased tmux links", function()
    local link = utils.get_link_at_cursor("[[tmux://session:window.0|agent]]")

    assert.is_true(utils.is_tmux("[[tmux://session:window.0|agent]]"))
    assert.are.equal("//session:window.0", link.target)
  end)

  it("finds the link when the cursor is on its alias", function()
    local line = "[[one.lua:1|first]] [[two.lua:2|second]]"
    local link = utils.get_link_at_cursor(line, line:find("second", 1, true))

    assert.are.equal("two.lua", link.file)
    assert.are.equal("2", link.target)
  end)
end)
