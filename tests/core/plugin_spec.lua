local assert = require("luassert")
local h = require("tests.unit_helpers")
local dummy_action = function() end

describe("a leader key", function()
  local function get_spec()
    return {
      {
        name = "neo-tree.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        keys = { { "<leader>fe", dummy_action, desc = "Explorer NeoTree" } },
      },
      {
        name = "telescope.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        keys = { { "<leader>ff", dummy_action, desc = "Find Files" } },
      },
      {
        name = "harpoon.nvim", -- plugin added by the user
        _ = { module = "plugins.editor" },
        keys = { { "<leader>f", dummy_action, desc = "Harpoon on leader f" } },
      },
    }
  end
  it("can be changed across all plugins defined in LazyVim", function()
    local opts = { leaders_to_change = { f = "F" } }
    local spec = get_spec()

    h.activate(opts, { spec = spec })

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>f" }, h.lazy_keys_result(spec))
  end)
end)

describe("menu items in gitsigns.nvim", function()
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
  it("can be changed when defined in LazyVim", function()
    local opts = { leaders_to_change = { g = "G" } }
    local spec = get_spec()

    h.activate(opts, { spec = spec })
    spec[1].opts.on_attach()
    spec[2].opts.on_attach()

    for _, key in ipairs({ "]h", "\\GhS", "\\GhR", "\\ihS", "\\ihR" }) do
      assert(h.has_key(key), "Key expected: " .. key)
    end
  end)
end)

describe("menu items in which-key.nvim", function()
  local menu_opts = { leaders_to_change = { s = "S" } }

  local function assert_plugin_opts(plugin, keys_expected)
    for _, key in ipairs(keys_expected) do
      assert(plugin.opts.defaults[key])
    end
  end
  local function get_spec(extra_spec)
    local result = {
      {
        name = "which-key.nvim",
        _ = { module = "lazyvim.plugins.editor" },
        opts = {
          defaults = {
            ["<leader>s"] = { name = "+search" },
            ["<leader>sn"] = { name = "+noice" },
            ["<leader>in"] = { name = "+justforthetest" },
          },
        },
      },
    }
    for _, spec in ipairs(extra_spec) do
      table.insert(result, spec)
    end
    return result
  end
  it("can be changed", function()
    local spec = get_spec({
      {
        name = "telescope.nvim", -- telescope using opts like which-key
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
    })

    h.activate(menu_opts, { spec = spec })

    -- Telescope and Harpoon keys
    assert.same({ "<leader>Sa", "<leader>sh" }, h.lazy_keys_result(spec))

    -- Changed which-key's opts, but not the fake telescope opts
    assert_plugin_opts(spec[1], { "<leader>S", "<leader>Sn", "<leader>in" })
    assert_plugin_opts(spec[2], { "<leader>s", "<leader>sn" })
  end)
  it("are changed only when defined in LazyVim", function()
    local function assert_description(plugin, key_expected, description_expected)
      assert(plugin.opts.defaults[key_expected]["name"] == description_expected)
    end
    local spec = get_spec({
      {
        name = "which-key.nvim", -- menu item for harpoon  added by the user
        _ = { module = "plugins.editor" },
        opts = {
          defaults = {
            ["<leader>s"] = { name = "+harpoon" },
          },
        },
      },
      {
        name = "harpoon.nvim", -- plugin added by the user
        _ = { module = "plugins.editor" },
        keys = { { "<leader>sh", dummy_action(), desc = "Harpoon on leader sh" } },
      },
    })

    h.activate(menu_opts, { spec = spec })

    -- Harpoon keys:
    assert.same({ "<leader>sh" }, h.lazy_keys_result(spec))

    --  Which-key's opts:
    assert_plugin_opts(spec[1], { "<leader>S", "<leader>Sn", "<leader>in" })
    assert_description(spec[1], "<leader>S", "+search")
    assert_description(spec[1], "<leader>Sn", "+noice")
    assert_plugin_opts(spec[2], { "<leader>s" })
    assert_description(spec[2], "<leader>s", "+harpoon")
  end)
end)
