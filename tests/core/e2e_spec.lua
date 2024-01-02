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
    local function no_event()
      return {}
    end
    local leaders_to_change = { g = "G", s = "S" }
    local Lazy = require("lazy")

    Lazy.setup({
      {
        "abeldekat/lazyflex.nvim", -- restrict the plugins to use...
        version = "*",
        import = "lazyflex.hook",
        opts = { lazyvim = { presets = { "coding", "editor" } }, kw = { "plen", "tokyo" } },
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
          -- keymaps adapter: Trigger keymaps
          require("lazyvim.config.keymaps") -- on very lazy, UIEnter is too late

          -- values adapter: trigger gitsigns. The test does not invoke gitsigns.opts
          local gitsigns = require("lazy.core.config").spec.plugins["gitsigns.nvim"]
          local gitsigns_opts = require("lazy.core.plugin").values(gitsigns, "opts", false)
          gitsigns_opts.on_attach() -- manually invoke on_attach
        end,
      },
      {
        "lewis6991/gitsigns.nvim", -- WORKAROUNDS...
        event = no_event,
        opts = {
          -- values adapter: In LazyVim, gitsigns on_attach mappings are buffer local...
          on_attach = function(_) -- override on_attach
            vim.keymap.set({ "n" }, "<leader>ghS", function() end, { desc = "Test Stage Buffer" })
          end,
        },
      },
    }, { install_missing = true })

    assert(h.has_key(" So")) -- search options --> plugins adapter
    assert(h.has_key(" Gg")) -- keymaps.lua --> keymaps adapter
    assert(h.has_key(" GhS")) -- gitsigns --> values adapter
  end)
end)
