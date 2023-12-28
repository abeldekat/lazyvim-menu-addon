Utils = require("lazymenu.utils")

---@class LazyMenuKeymapsAdapter
local M = {}

---@return string[]
function M.leaders()
  return { "<leader>c" }
end

---@param remap_cb fun(safe_keymap_set_cb:fun(), to_change:table<string,string>)
---@param to_change table<string,string>
function M.setup(remap_cb, to_change)
  Utils.on_load("LazyVim", function()
    local Util = require("lazyvim.util")
    local safe_keymap_set = Util.safe_keymap_set
    local safe_keymap_set_decorated = remap_cb(safe_keymap_set, to_change)

    ---@diagnostic disable-next-line: duplicate-set-field
    Util.safe_keymap_set = function(mode, lhs, rhs, opts)
      safe_keymap_set_decorated(mode, lhs, rhs, opts)
    end
  end)
end
return M
