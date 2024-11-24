local plugin = require("navigate-note")

describe("setup", function()
  it("works with default", function()
    assert(plugin.setup() == nil, "Successfully setup!")
  end)
end)
