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
        opts = function()
          -- For some reason, the autocommand in on_load is not triggered inside the test
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
        opts = function()
          require("lazyvim.config.keymaps") -- on very lazy, UIEnter is too late
        end,
      },
    }, { install_missing = true })

    assert(h.has_key(" So")) -- search options --> plugins adapter
    assert(h.has_key(" Gg")) -- keymaps.lua --> keymaps adapter
  end)
end)
