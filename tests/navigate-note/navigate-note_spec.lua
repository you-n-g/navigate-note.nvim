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
