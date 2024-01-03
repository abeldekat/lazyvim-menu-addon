--[[
Test the adapters injecting code into LazyVim and lazy.nvim.
--]]
-- NOTE: --> lsp adapter: Not tested in e2e.

local assert = require("luassert")
local h = require("tests.unit_helpers")

local function get_dir()
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h:h") or ""
end

describe("lazymenu.nvim", function()
  before_each(function()
    vim.g.lazy_did_setup = false
    vim.go.loadplugins = true
    for modname in pairs(package.loaded) do
      if string.lower(modname):find("lazy") == 1 then
        package.loaded[modname] = nil
      end
    end
  end)
  it("integrates with LazyVim", function()
    local leaders_to_change = { c = "C", g = "G", s = "S" }
    local Lazy = require("lazy")

    Lazy.setup({ -- test using 12 plugins, including lazy and LazyVim
      {
        "abeldekat/lazyflex.nvim", -- restrict the plugins to use...
        version = "*",
        import = "lazyflex.hook",
        opts = {
          enable_match = false,
          -- only keep init and colorsscheme
          lazyvim = { presets = { "coding", "editor", "formatting", "linting", "lsp", "treesitter", "ui" } },
          override_kw = { "gitsi", "which", "telesc" },
        },
      },
      {
        "abeldekat/lazymenu.nvim",
        dir = get_dir(),
        import = "lazymenu.hook",
        opts = function() -- WORKAROUNDS...
          -- keymaps adapter: The autocommand in on_load is not triggered inside the test
          ---@diagnostic disable-next-line: duplicate-set-field
          require("lazymenu.adapters.utils").on_load = function(name, callback)
            callback(name) -- load immediately
          end

          return { leaders_to_change = leaders_to_change }
        end,
      },
      {
        "LazyVim/LazyVim",
        import = "lazyvim.plugins",
        opts = function(_, _) -- WORKAROUNDS...
          -- values adapter: Trigger gitsigns. The test does not invoke gitsigns plugin.opts
          local gitsigns = require("lazy.core.config").spec.plugins["gitsigns.nvim"]
          local gitsigns_opts = require("lazy.core.plugin").values(gitsigns, "opts", false)
          gitsigns_opts.on_attach(0) -- manually invoke on_attach

          -- keymaps adapter: Trigger keymaps in keymaps.lua
          require("lazyvim.config.keymaps") -- on very lazy, UIEnter is too late

          -- lsp adapter: Trigger the keymaps for the lps. Buffer 0
          require("lazyvim.plugins.lsp.keymaps").on_attach(_, 0)
        end,
      },
      {
        "lewis6991/gitsigns.nvim", -- WORKAROUNDS...
        opts = {
          -- values adapter: During test, the gitsigns spec in LazyVim contains package.loaded.gitsigns == nil
          on_attach = function(buffer) -- override on_attach
            vim.keymap.set({ "n" }, "<leader>ghS", function() end, { buffer = buffer, desc = "Test Stage Buffer" })
          end,
        },
      },
    }, { install_missing = true })

    assert(h.has_key(" So")) -- search options --> plugins adapter
    assert(h.has_key(" GhS", 0)) -- gitsigns --> values adapter
    assert(h.has_key(" Gg")) -- keymaps.lua --> keymaps adapter
    assert(h.has_key(" Cl", 0)) -- lsp --> lsp adapter
  end)
end)
