local h = require("tests.unit_helpers")
local dummy_action = function() end

describe("a leader key", function()
  local function get_spec()
    return {
      {
        name = "neo-tree.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        keys = { { "<leader>fe", dummy_action(), desc = "Explorer NeoTree" } },
      },
      {
        name = "telescope.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        keys = { { "<leader>ff", dummy_action(), desc = "Find Files" } },
      },
      {
        name = "harpoon.nvim",
        _ = { module = "plugins.editor" },
        keys = { { "<leader>f", dummy_action(), desc = "Harpoon on leader f" } },
      },
    }
  end
  it("can be changed accross all plugins defined in LazyVim", function()
    local opts = { to_change = { f = "F" } }
    local spec = get_spec()

    h.activate(opts, spec)

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>f" }, h.all_keys(spec))
  end)
end)
