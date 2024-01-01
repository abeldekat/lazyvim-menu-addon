local Utils = require("lazymenu.domain.utils")
local M = {}

-- Property is a function executing vim.keymap.set
--- @param property function
local function decorate_function_in(property)
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
local function change_values_in(property)
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
function M.remap(plugin, property_name)
  local opts_original = plugin.opts

  ---@param self LazyPlugin
  ---@param opts_in table
  ---@return table
  return function(self, opts_in) -- decorate plugin.opts
    local function from_original()
      if type(opts_original) == "function" then
        return opts_original(self, opts_in) or opts_in
      end
      return vim.tbl_deep_extend("force", opts_original, opts_in or {})
    end

    local opts = from_original()
    if opts and opts[property_name] then
      local target = opts[property_name]
      opts[property_name] = type(target) == "function" and decorate_function_in(target) or change_values_in(target)
    end
    return opts
  end
end

return M
