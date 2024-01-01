---@class LazyMenuPluginAdapter
local M = {}

---@return LazyMenuConfig
function M.get_opts()
  local lazymenu_plugin = require("lazy.core.config").spec.plugins["lazymenu.nvim"]

  ---@type LazyMenuConfig | fun(LazyPlugin, opts:table):LazyMenuConfig
  local opts = lazymenu_plugin.opts or {}
  if type(opts) == "function" then
    return opts(lazymenu_plugin, {})
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
