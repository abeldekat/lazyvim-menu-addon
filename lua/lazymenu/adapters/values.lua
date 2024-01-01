---@class LazyMenuValuesAdapter
local M = {}

---@param change_cb fun(add_cb:fun())
function M.inject(change_cb) -- on load: change keys defined inside opts
  local Plugin = require("lazy.core.plugin")
  local values_decorated = change_cb(Plugin.values)

  ---@diagnostic disable-next-line: duplicate-set-field
  Plugin.values = function(plugin, prop, is_list)
    return values_decorated(plugin, prop, is_list)
  end
end

return M
