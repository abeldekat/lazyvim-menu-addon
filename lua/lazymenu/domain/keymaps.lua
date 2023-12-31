local Utils = require("lazymenu.domain.utils")
---@class LazyMenuKeymapsDomain
local M = {}

-- Remaps keys defined in LazyVim's keymaps.lua
-- Is activated when LazyVim is loaded
function M.remap(adapter_cb)
  -- See lazyvim.util.init.safe_keymap_set
  return function(mode, lhs, rhs, opts)
    adapter_cb(mode, Utils.change_when_matched(lhs), rhs, opts)
  end
end

return M
