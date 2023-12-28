Utils = require("lazymenu.utils")

---@class LazyMenuKeymapsAdapter
local M = {}

---@return string[]
function M.leaders()
  return { "<leader>c" }
end

---@param remap_cb fun(remap_keymaps_cb:fun(), mappings:string[])
---@param mappings string[]
function M.setup(remap_cb, mappings)
  Utils.on_load("LazyVim", function()
    local Util = require("lazyvim.util")
    local safe_keymap_set = Util.safe_keymap_set
    local safe_keymap_set_decorated = remap_cb(safe_keymap_set, mappings)

    ---@diagnostic disable-next-line: duplicate-set-field
    Util.safe_keymap_set = function(mode, lhs, rhs, opts)
      safe_keymap_set_decorated(mode, lhs, rhs, opts)
    end
  end)
end
return M
