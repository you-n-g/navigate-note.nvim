local plugin = require("navigate-note")
local tmux = require("navigate-note.tmux")
local utils = require("navigate-note.utils")

describe("setup", function()
  it("works with default", function()
    assert(plugin.setup() == nil, "Successfully setup!")
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
