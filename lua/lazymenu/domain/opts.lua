local Utils = require("lazymenu.domain.utils")
local M = {}

-- Property is a function executing vim.keymap.set
--- @param property function
local function function_strategy(property)
  if not type(property) == "function" then
    return property
  end

  local property_org = property
  property = function(...)
    local set_org = vim.keymap.set

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.keymap.set = function(mode, l, r, opts) -- attach
      set_org(mode, Utils.change_when_matched(l), r, opts)
    end
    property_org(...)
    vim.keymap.set = set_org -- release
  end

  return property
end

-- Property contains key-value pairs to change
--- @param property table
local function table_strategy(property)
  if not type(property) == "table" then
    return property
  end

  local result = {}
  for key, value in pairs(property) do
    result[Utils.change_when_matched(key)] = value
  end
  return result
end

-- The opts table or opts function of a plugin contain keys that need to change
-- --> Decorate the opts function to remap when loaded by lazy.nvim
---@param plugin LazyPlugin
---@param property_name string
---@param property_type string
function M.remap(plugin, property_name, property_type)
  local opts_original = plugin.opts

  ---@param self LazyPlugin
  ---@param opts table
  ---@return table
  return function(self, opts) -- decorate plugin.opts
    local function from_original()
      if type(opts_original) == "function" then
        return opts_original(self, opts) or opts
      end
      return vim.tbl_deep_extend("force", opts_original, opts or {})
    end

    local opts_result = from_original()
    if opts_result[property_name] then
      opts_result[property_name] = property_type == "function" and function_strategy(opts_result[property_name])
        or table_strategy(opts_result[property_name])
    end
    return opts_result
  end
end

return M
