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

---@param remap_cb fun(add_cb:fun())
function M.inject(remap_cb)
  local Spec = require("lazy.core.plugin").Spec
  local add = Spec.add
  local add_decorated = remap_cb(add)

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.add = function(_, plugin, results)
    return add_decorated(_, plugin, results)
  end

  -- detach when done
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      Spec.add = add
    end,
  })
end

return M
