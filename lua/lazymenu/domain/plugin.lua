local Config = require("lazymenu.config")
local Opts = require("lazymenu.domain.opts")
local Utils = require("lazymenu.domain.utils")

---@class LazyMenuPluginDomain
local M = {}

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
function M.remap(add_cb)
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

    for name, config in pairs(Config.options.keys_in_opts) do
      if name == plugin.name and plugin.opts then
        plugin.opts = Opts.remap(plugin, config.property, config.type)
      end
    end

    return plugin
  end
end

return M
