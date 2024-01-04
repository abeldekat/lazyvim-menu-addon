local Config = require("lazyvim_menu_addon.config")
local Utils = require("lazyvim_menu_addon.domain.utils")

---@class LazyVimMenuAddonPluginDomain
local M = {}

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
    prop_org(...) -- Example: Calls the rhs of gitsigns: on_attach = function(buffer) ...code... end
    vim.keymap.set = set_org -- release
  end

  return prop_as_function
end

-- Change leader keys in plugin.opts
-- Supports two approaches:
--   1. The keys are property values in the opts table: --> Change the keys. Example: which-key.nvim
--   2. The keys are in a rhs function in the opts table: --> Decorate the function. Example: gitsigns.nvim
local function change_opts(plugin)
  local opts = plugin.opts
  for name, config in pairs(Config.options.keys_in_opts) do
    if name == plugin.name then
      local target = opts[config.property]
      if target then
        opts[config.property] = type(target) == "function" and decorate_function_in(target) or change_in(target)
      end
    end
  end
  return opts
end

-- Change leader keys in plugin.opts
local function change_keys(keys)
  return vim.tbl_map(function(lazy_mapping)
    lazy_mapping[1] = Utils.change_when_matched(lazy_mapping[1])
    return lazy_mapping
  end, keys)
end

-- Change leader keys in plugin.keys
-- Change leader keys in plugin.opts
-- In LazyVim v10.8.2, plugin.keys is always a table(mini.surround does not contain leader keys)
--
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
---@return fun(_, plugin:LazyPlugin, results?:string[]):LazyPlugin
function M.change(add_cb)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results) -- LazySpec
    plugin = add_cb(_, plugin, results) -- add and merge the fragment

    if not (plugin and type(plugin) == "table" and Utils.is_lazyvim_fragment(plugin)) then
      return plugin -- do not change plugin fragments defined by the user
    end

    local keys = rawget(plugin, "keys")
    if keys and type(keys) == "table" then
      plugin.keys = change_keys(keys)
    end

    local opts = rawget(plugin, "opts")
    if opts and type(opts) == "table" then
      plugin.opts = change_opts(plugin)
    end

    return plugin
  end
end

return M
