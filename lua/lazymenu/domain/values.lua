local Config = require("lazymenu.config")
local Utils = require("lazymenu.domain.utils")

---@class LazyMenuValuesDomain
local M = {}

-- Property is a function executing vim.keymap.set
--- @param prop_as_function function
local function decorate_function_in(prop_as_function)
  if not type(prop_as_function) == "function" then
    return prop_as_function
  end

  local prop_org = prop_as_function
  prop_as_function = function(...)
    local set_org = vim.keymap.set

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.keymap.set = function(mode, l, r, opts) -- attach
      set_org(mode, Utils.change_when_matched(l), r, opts)
    end
    prop_org(...)
    vim.keymap.set = set_org -- release
  end

  return prop_as_function
end

-- Property contains key-value pairs to change
--- @param prop_as_table table
local function change_in(prop_as_table)
  if not type(prop_as_table) == "table" then
    return prop_as_table
  end

  local result = {}
  for key, value in pairs(prop_as_table) do
    result[Utils.change_when_matched(key)] = value
  end
  return result
end

-- Remap leader keys in plugin.opts
-- Supports two approaches:
--   1. The keys are property values in the opts table: --> Change the keys. Example: which-key.nvim
--   2. The keys are in a rhs function in the opts table: --> Decorate the function. Example: gitsigns.nvim
--
-- This could also be achieved by decorating each plugin.opts with a function when applicable
-- However, using that approach, lazymenu.nvim would be responsible for the merging algorithm
-- The merging algorithm is more complex than just vim.tbl_deep_extend
-- See lazy.core.plugin._values and lazy.core.util.merge
--
---@param values_cb fun(plugin:LazyPlugin, prop:string, is_list?:boolean)
---@return fun(plugin:LazyPlugin, prop:string, is_list?:boolean):table
function M.change(values_cb)
  -- See lazy.core.plugins.values
  ---@param plugin LazyPlugin
  ---@param prop string
  ---@param is_list? boolean
  return function(plugin, prop, is_list)
    local result = values_cb(plugin, prop, is_list)
    if prop ~= "opts" then
      return result
    end

    local opts = result -- the final opts, lazy.nvim has performed the merging
    for name, config in pairs(Config.options.keys_in_opts) do
      if name == plugin.name then
        local target = opts[config.property]
        opts[config.property] = type(target) == "function" and decorate_function_in(target) or change_in(target)
      end
    end

    return opts
  end
end

return M
