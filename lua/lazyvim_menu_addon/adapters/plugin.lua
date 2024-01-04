---@class LazyVimMenuAddonPluginAdapter
local M = {}

---@return LazyVimMenuAddonConfig
function M.get_opts()
  local plugin = require("lazy.core.config").spec.plugins["lazyvim-menu-addon"]

  ---@type LazyVimMenuAddonConfig | fun(LazyPlugin, opts:table):LazyVimMenuAddonConfig
  local opts = plugin.opts or {}
  if type(opts) == "function" then
    return opts(plugin, {})
  end
  return opts
end

---@param change_cb fun(add_cb:fun())
function M.inject(change_cb)
  local Spec = require("lazy.core.plugin").Spec
  local add_decorated = change_cb(Spec.add)

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.add = function(_, plugin, results)
    return add_decorated(_, plugin, results)
  end
end

return M
