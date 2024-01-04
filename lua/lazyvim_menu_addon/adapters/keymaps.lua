---@class LazyVimMenuAddonKeymapsAdapter
local M = {}

---@param change_cb fun(safe_keymap_set_cb:fun())
function M.inject(change_cb)
  require("lazyvim_menu_addon.adapters.utils").on_load("LazyVim", function()
    local LazyVimUtil = require("lazyvim.util")
    local safe_keymap_set_decorated = change_cb(LazyVimUtil.safe_keymap_set)

    ---@diagnostic disable-next-line: duplicate-set-field
    LazyVimUtil.safe_keymap_set = function(mode, lhs, rhs, opts)
      safe_keymap_set_decorated(mode, lhs, rhs, opts)
    end
  end)
end
return M
