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

    for name, config in pairs(Config.options.keys_in_opts) do
      if name == plugin.name then
        local target = result[config.property]
        result[config.property] = type(target) == "function" and decorate_function_in(target) or change_in(target)
      end
    end

    return result
  end
end

return M
