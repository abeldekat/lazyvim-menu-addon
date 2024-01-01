local Utils = require("lazymenu.domain.utils")

---@class LazyMenuPluginDomain
local M = {}

-- Remap leader keys in plugin.keys
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
---@return fun(_, plugin:LazyPlugin, results?:string[]):LazyPlugin
function M.change(add_cb)
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
        lazy_mapping[1] = Utils.change_when_matched(lazy_mapping[1])
        return lazy_mapping
      end, plugin.keys)
    end

    return plugin
  end
end

return M
