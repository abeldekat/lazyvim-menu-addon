local Utils = require("lazymenu.domain.utils")

---@class LazyMenuPluginDomain
local M = {}

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
---@param to_change table<string,string>
function M.remap(add_cb, to_change)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results)
    local fragment_has_keys = plugin and type(plugin) == "table" and plugin.keys and type(plugin.keys) == "table"
    plugin = add_cb(_, plugin, results) -- add and merge the fragment
    if not Utils.is_lazyvim_fragment(plugin) then
      return plugin -- do not change plugin fragments defined by the user
    end

    if fragment_has_keys then
      plugin.keys = vim.tbl_map(function(lazy_mapping)
        for key, value in pairs(to_change) do
          if lazy_mapping[1]:find(key, 1, true) then
            lazy_mapping[1] = lazy_mapping[1]:gsub(key, value)
          end
        end
        return lazy_mapping
      end, plugin.keys)
    end
    return plugin
  end
end

return M
