local M = {}

-- The fragment of a plugin is defined in LazyVim, not by the user
---@param plugin LazyPlugin
function M.is_lazyvim_fragment(plugin)
  return plugin and plugin._ and plugin._.module and plugin._.module:find("lazyvim", 1, true)
end

return M
