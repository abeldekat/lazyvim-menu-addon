---@class LazyMenuWhichKeyAdapter
local M = {}

---@param remap_cb fun(values_cb:fun(), to_change:table<string,string>)
---@param to_change table<string,string>
function M.setup(remap_cb, to_change)
  local Plugin = require("lazy.core.plugin")
  local values_decorated = remap_cb(Plugin._values, to_change)

  ---@diagnostic disable-next-line: duplicate-set-field
  Plugin._values = function(root, plugin, prop, is_list)
    return values_decorated(root, plugin, prop, is_list)
  end
end

return M
