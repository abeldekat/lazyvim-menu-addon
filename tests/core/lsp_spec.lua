local h = require("tests.unit_helpers")
local dummy_action = function() end

describe("keymaps configured in lazyvim.plugins.lsp.keymaps", function()
  local keyspec = {
    { "gd", dummy_action, desc = "Goto Definition" },
    { "<leader>cl", dummy_action, desc = "Lsp Info" },
    { "<leader>ca", dummy_action, desc = "Code Action" },
    { "<leader>il", dummy_action, desc = "Test not modified" },
  }
  it("are changed on lsp attach", function()
    local opts = { leaders_to_change = { c = "C" } }
    h.activate(opts, { keyspec = keyspec })

    for _, key in ipairs({ "gd", "\\Cl", "\\Ca", "\\il" }) do
      assert(h.has_key(key), "Key expected: " .. key)
    end
  end)
end)
