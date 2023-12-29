local Utils = require("lazymenu.domain.utils")

---@class LazyMenuWhichKeyDomain
local M = {}

-- Remaps keys defined in the opts of LazyVim's which-key definitions
-- Needs to hook into the merging of opts before calling config,
-- because the keys are defined in opts and opts can be a function(see ui.lua, noice.nvim)
---@param adapter_cb fun(root:LazyPlugin, plugin:LazyPlugin, prop:string, is_list?:boolean)
---@param to_change table<string,string>
function M.remap(adapter_cb, to_change)
  -- See lazy.core.plugins._values
  ---@param root LazyPlugin
  ---@param plugin LazyPlugin
  ---@param prop string
  ---@param is_list? boolean
  return function(root, plugin, prop, is_list)
    if not (plugin and plugin.name == "which-key.nvim" and prop == "opts" and Utils.is_lazyvim_fragment(plugin)) then
      return adapter_cb(root, plugin, prop, is_list)
    end

    local result = adapter_cb(root, plugin, prop, is_list)
    local new_keys = {}
    for key, desc in pairs(result.defaults) do
      local key_to_use = key
      for key_to_change, new_key in pairs(to_change) do
        if key:find(key_to_change, 1, true) then
          key_to_use = key:gsub(key_to_change, new_key)
          break
        end
      end
      new_keys[key_to_use] = desc
    end
    result.defaults = new_keys
    return result
  end
end
return M
