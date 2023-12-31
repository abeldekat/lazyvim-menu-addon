Utils = require("lazymenu.adapters.utils")

---@class LazyMenuSafeKeymapSetAdapter
local M = {}

---@param remap_cb fun(safe_keymap_set_cb:fun())
function M.inject(remap_cb)
  Utils.on_load("LazyVim", function()
    local Util = require("lazyvim.util")
    local safe_keymap_set_decorated = remap_cb(Util.safe_keymap_set)

    ---@diagnostic disable-next-line: duplicate-set-field
    Util.safe_keymap_set = function(mode, lhs, rhs, opts)
      safe_keymap_set_decorated(mode, lhs, rhs, opts)
    end
  end)
end
return M
