local Config = require("lazymenu.config")
local M = {}

-- The fragment of a plugin is defined in LazyVim, not by the user
---@param plugin LazyPlugin
function M.is_lazyvim_fragment(plugin)
  return plugin and plugin._ and plugin._.module and plugin._.module:find("lazyvim", 1, true)
end

-- Return a new key when key is in leaders_to_change
-- Otherwise, return the key unchanged
---@param key string
---@return string
function M.change_when_matched(key)
  local result = key
  for leader, new_leader in pairs(Config.options.leaders_to_change) do
    if key:find(leader, 1, true) then
      result = key:gsub(leader, new_leader)
      break
    end
  end
  return result
end

return M
