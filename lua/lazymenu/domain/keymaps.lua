---@class LazyMenuKeymapsDomain
local M = {}

-- Remaps keys defined in LazyVim's keymaps.lua
-- Is activated when LazyVim is loaded
function M.remap(adapter_cb, to_change)
  -- See lazyvim.util.init.safe_keymap_set
  return function(mode, lhs, rhs, opts)
    for key, value in pairs(to_change) do
      if lhs:find(key, 1, true) then
        lhs = lhs:gsub(key, value)
      end
    end
    adapter_cb(mode, lhs, rhs, opts)
  end
end

return M
