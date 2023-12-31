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
    local opts = { leaders_to_change = { f = "F" } }
    local spec = get_spec()

    h.activate(opts, spec)

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>f" }, h.lazy_keys_result(spec))
  end)
end)

-- NOTE: lazy.nvim: this also works with multiple which-key fragments
describe("menu items from which-key.nvim", function()
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
      local plugin_result =
        vim.tbl_keys(type(plugin.opts) == "function" and plugin.opts().defaults or plugin.opts.defaults)
      assert(#plugin_result == 2)
      assert(vim.tbl_contains(plugin_result, leader_one))
      assert(vim.tbl_contains(plugin_result, leader_two))
    end
    local opts = { leaders_to_change = { s = "S" } }
    local spec = get_spec()

    h.activate(opts, spec)

    -- Changed telescope key, but not the key for Harpoon:
    assert.same({ "<leader>Sa", "<leader>sh" }, h.lazy_keys_result(spec))

    -- Changed which-key's opts, but not the fake telescope opts
    assert_plugin_opts(spec[1], "<leader>S", "<leader>Sn")
    assert_plugin_opts(spec[2], "<leader>s", "<leader>sn")
  end)
end)

-- NOTE: lazy.nvim: this also works with multiple which-key fragments
describe("menu items from gitsigns.nvim", function()
  local function get_spec()
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { desc = desc })
    end
    return {
      {
        name = "gitsigns.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        opts = {
          on_attach = function() -- buffer
            map("n", "]h", dummy_action, "Next Hunk")
            map("n", "<leader>ghS", dummy_action, "Stage Buffer")
            map("n", "<leader>ghR", dummy_action, "Reset Buffer")
          end,
        },
      },
      {
        name = "gitsigns.nvim",
        _ = { module = "plugins.editor" },
        opts = {
          on_attach = function() -- buffer
            map("n", "<leader>ihS", dummy_action, "Stage Buffer")
            map("n", "<leader>ihR", dummy_action, "Reset Buffer")
          end,
        },
      },
    }
  end
  it("will be changed when defined in LazyVim", function()
    local function has_key(key)
      for _, item in ipairs(vim.api.nvim_get_keymap("n")) do
        if key == item.lhs then
          return true
        end
      end
      return false
    end
    local opts = { leaders_to_change = { g = "G" } }
    local spec = get_spec()

    h.activate(opts, spec)
    spec[1].opts().on_attach()
    spec[2].opts.on_attach()

    for _, key in ipairs({ "]h", "\\GhS", "\\GhR", "\\ihS", "\\ihR" }) do
      assert(has_key(key), "Key expected: " .. key)
    end
  end)
end)
