local M = {}

function M.get_opts()
  local lazymenu_plugin = require("lazy.core.config").spec.plugins["lazymenu.nvim"]
  local opts = lazymenu_plugin.opts or {}

  if type(opts) == "function" then
    return opts(lazymenu_plugin, {})
  end
  return opts
end

function M.setup(should_remap_cb, remap_cb)
  local Spec = require("lazy.core.plugin").Spec
  local add = Spec.add

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.add = function(_, plugin)
    local should_remap = should_remap_cb(plugin)
    add(_, plugin)
    if should_remap then
      remap_cb(_, plugin)
    end
    return plugin
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
