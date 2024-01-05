local assert = require("luassert")
local h = require("tests.unit_helpers")
local dummy_action = function() end

--- Returns all "lhs" from each plugin.keys
--- In the unit tests, plugin.keys should be of type LazyKeysSpec[]
---@return string[]
local function lazy_keys_result(spec)
  local result = {}
  for _, plugin in ipairs(spec) do
    if plugin.keys then
      for _, key in ipairs(plugin.keys) do
        table.insert(result, key[1])
      end
    end
  end
  return result
end

describe("a leader key inside plugin.keys", function()
  local opts = { leaders_to_change = { f = "F" } }
  local function get_spec(extraspec)
    local spec = {
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
        keys = { { "<leader>ff", dummy_action, desc = "Harpoon ui" } },
      },
    }
    vim.tbl_extend("force", spec, extraspec or {})
    return spec
  end
  it("can be changed across all plugins defined in LazyVim", function()
    local spec = get_spec()

    h.activate(opts, { spec = spec })

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>ff" }, lazy_keys_result(spec))
  end)
  it("can be changed when plugin.keys is a function ", function()
    local spec = get_spec({
      {
        name = "harpoon.nvim",
        keys = function(_, keys)
          table.insert(keys, { "<leader>fa", dummy_action(), desc = "Harpoon add" })
        end,
      },
    })

    h.activate(opts, { spec = spec })

    assert.same({ "<leader>Fe", "<leader>Ff", "<leader>ff", "<leader>fa" }, lazy_keys_result(spec))
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
    local opts = type(plugin.opts) == "function" and plugin.opts(_, {}) or plugin.opts
    for _, key in ipairs(keys_expected) do
      assert(opts.defaults[key])
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
            ["<leader>in"] = { name = "+justforthetest" },
          },
        },
      },
      {
        name = "which-key.nvim",
        _ = { module = "lazyvim.plugins.ui" },
        opts = function(_, opts)
          opts.defaults = {
            ["<leader>sn"] = { name = "+noice" },
          }
          return opts
        end,
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
    assert.same({ "<leader>Sa", "<leader>sh" }, lazy_keys_result(spec))

    -- Changed which-key's opts, but not the fake telescope opts
    assert_plugin_opts(spec[1], { "<leader>S", "<leader>in" })
    assert_plugin_opts(spec[2], { "<leader>Sn" })
    assert_plugin_opts(spec[3], { "<leader>s", "<leader>sn" })
  end)

  it("are changed only when defined in LazyVim", function()
    local function assert_description(plugin, key_expected, description_expected)
      local opts = type(plugin.opts) == "function" and plugin.opts(_, {}) or plugin.opts
      assert(opts.defaults[key_expected]["name"] == description_expected)
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
    assert.same({ "<leader>sh" }, lazy_keys_result(spec))

    --  Which-key's opts:
    assert_plugin_opts(spec[1], { "<leader>S", "<leader>in" })
    assert_description(spec[1], "<leader>S", "+search")
    assert_plugin_opts(spec[2], { "<leader>Sn" })
    assert_description(spec[2], "<leader>Sn", "+noice")
    assert_plugin_opts(spec[3], { "<leader>s" })
    assert_description(spec[3], "<leader>s", "+harpoon")
  end)
end)
