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
        name = "harpoon.nvim", -- plugin added by the user
        _ = { module = "plugins.editor" },
        keys = { { "<leader>f", dummy_action(), desc = "Harpoon on leader f" } },
      },
    }
  end
  it("can be changed across all plugins defined in LazyVim", function()
    local opts = { to_change = { f = "F" } }
    local spec = get_spec()

    h.activate(opts, spec)

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>f" }, h.lazy_keys_result(spec))
  end)
end)

-- NOTE: with lazy.nvim, this alsow works with multiple which-key fragments
-- that might have opts as a function
--
describe("which-keys menu items", function()
  local function get_spec()
    return {
      {
        name = "which-key.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        opts = {
          defaults = {
            ["<leader>s"] = { name = "+search" },
            ["<leader>sn"] = { name = "+noice" },
          },
        },
      },
      {
        name = "telescope.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        keys = { { "<leader>sa", dummy_action(), desc = "Auto Commands" } },
        opts = { -- just for testing:
          defaults = {
            ["<leader>s"] = { name = "+search" },
            ["<leader>sn"] = { name = "+noice" },
          },
        },
      },
      {
        name = "harpoon.nvim", -- plugin added by the user
        _ = { module = "plugins.editor" },
        keys = { { "<leader>sh", dummy_action(), desc = "Harpoon on leader sh" } },
      },
    }
  end
  it("will be changed when defined in LazyVim", function()
    local function assert_plugin_opts(plugin, leader_one, leader_two)
      local plugin_result = vim.tbl_keys(plugin.opts.defaults)
      assert(#plugin_result == 2)
      assert(vim.tbl_contains(plugin_result, leader_one))
      assert(vim.tbl_contains(plugin_result, leader_two))
    end
    local opts = { to_change = { s = "S" } }
    local spec = get_spec()

    h.activate(opts, spec)

    -- Changed telescope key, but not the key for Harpoon:
    assert.same({ "<leader>Sa", "<leader>sh" }, h.lazy_keys_result(spec))

    -- Changed which-key opts, but not the fake telescope opts
    assert_plugin_opts(spec[1], "<leader>S", "<leader>Sn")
    assert_plugin_opts(spec[2], "<leader>s", "<leader>sn")
  end)
end)
