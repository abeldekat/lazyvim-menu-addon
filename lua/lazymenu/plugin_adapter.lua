---@class LazyMenuPluginAdapter
local M = {}

---@return LazyMenuOptions
function M.get_opts()
  local lazymenu_plugin = require("lazy.core.config").spec.plugins["lazymenu.nvim"]

  ---@type LazyMenuOptions | fun(LazyPlugin, opts:table):LazyMenuOptions
  local opts = lazymenu_plugin.opts or {}
  if type(opts) == "function" then
    return opts(lazymenu_plugin, {})
  end
  return opts
end

---@generic T fun(_, plugin:LazyPlugin, results?:string[])
---@param remap_cb fun(add_fragment_cb: T, opts:LazyMenuOptions):T
---@param opts LazyMenuOptions
function M.setup(remap_cb, opts)
  local Spec = require("lazy.core.plugin").Spec
  local add_orig = Spec.add
  local add_decorated = remap_cb(add_orig, opts)

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.add = function(_, plugin, results)
    return add_decorated(_, plugin, results)
  end

  -- detach when done
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      Spec.add = add_orig
    end,
  })
end

return M
