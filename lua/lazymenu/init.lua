--[[
TODO: Make the lsp and keymaps leaders configurable

Example: Rename leader c to leader C:
--> Mason: from plugin
--> Format Injected Langs: from plugin
--> LSP items: The keys are created on_attach for each buffer:
  source action, code action, lsp info, rename
--> Config.keymaps.lua: Format and Line diagnostics
--> Which-key: the ["<leader>c"] = "+coding" definition in opts.defaults
--]]
local M = {}

-- Return the opts for this plugin
---@param adapter LazyMenuPluginAdapter
---@return LazyMenuOptions
local function get_opts(adapter)
  local opts = adapter.get_opts()
  opts = require("lazymenu.config").setup(opts)
  return opts
end

-- The fragment of a plugin is defined in LazyVim, not by the user
---@param plugin LazyPlugin
local function is_lazyvim_fragment(plugin)
  return plugin and plugin._ and plugin._.module and plugin._.module:find("lazyvim", 1, true)
end

-- Reduce the "to_change" table to contain only leaders defined in "leaders"
---@param to_change table<string,string>
---@param leaders string[]
---@return table<string,string>
local function reduce(to_change, leaders)
  local result = {}
  for key, value in pairs(to_change) do
    for _, leader in ipairs(leaders) do
      if key == leader then
        result[key] = value
      end
    end
  end
  return result
end

-- Remaps keys defined in LazyVim's keymaps.lua
-- Is activated when LazyVim is loaded
local function remap_keymaps(safe_keymap_set_cb, to_change)
  -- See lazyvim.util.init.safe_keymap_set
  return function(mode, lhs, rhs, opts)
    for key, value in pairs(to_change) do
      if lhs:find(key, 1, true) then
        lhs = lhs:gsub(key, value)
      end
    end
    safe_keymap_set_cb(mode, lhs, rhs, opts)
  end
end

-- NOTE: LazyVim defines lsp keymapping in LazyKeysSpec format
--
-- Remaps keys in LazyVim's lsp plugins definitions after the plugin has been added
-- Is activated when LazyVim is loaded
---@param resolve_lsp_cb fun(spec?:(string|LazyKeysSpec)[])
---@param to_change table<string,string>
local function remap_lsp(resolve_lsp_cb, to_change)
  -- See lazy.core.handler.keys.resolve
  ---@param spec? (string|LazyKeysSpec)[]
  return function(spec)
    if spec and type(spec) == "table" then
      spec = vim.tbl_map(function(spec_item)
        for key, value in pairs(to_change) do
          if spec_item[1]:find(key, 1, true) then
            spec_item[1] = spec_item[1]:gsub(key, value)
          end
        end
        return spec_item
      end, spec)
    end
    return resolve_lsp_cb(spec)
  end
end

-- Remaps keys defined in the opts of LazyVim's which-key definitions
-- Needs to hook into the merging of opts before calling config,
-- because the keys are defined in opts and opts can be a function(see ui.lua, noice.nvim)
---@param values_cb fun(root:LazyPlugin, plugin:LazyPlugin, prop:string, is_list?:boolean)
---@param to_change table<string,string>
local function remap_which_key(values_cb, to_change)
  -- See lazy.core.plugins._values
  ---@param root LazyPlugin
  ---@param plugin LazyPlugin
  ---@param prop string
  ---@param is_list? boolean
  return function(root, plugin, prop, is_list)
    if not (plugin and plugin.name == "which-key.nvim" and prop == "opts" and is_lazyvim_fragment(plugin)) then
      return values_cb(root, plugin, prop, is_list)
    end

    local result = values_cb(root, plugin, prop, is_list)
    local new_keys = {}
    for key, desc in pairs(result.defaults) do
      local key_to_use = key
      for key_to_change, new_key in pairs(to_change) do
        if key:find(key_to_change, 1, true) then
          key_to_use = key:gsub(key_to_change, new_key)
          break
        end
      end
      new_keys[key_to_use] = desc
    end
    result.defaults = new_keys
    return result
  end
end

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
---@param to_change table<string,string>
local function remap_plugins(add_cb, to_change)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results)
    local fragment_has_keys = plugin and type(plugin) == "table" and plugin.keys and type(plugin.keys) == "table"
    plugin = add_cb(_, plugin, results) -- add and merge the fragment
    if not is_lazyvim_fragment(plugin) then
      return plugin -- do not change plugin fragments defined by the user
    end

    if fragment_has_keys then
      plugin.keys = vim.tbl_map(function(lazy_mapping)
        for key, value in pairs(to_change) do
          if lazy_mapping[1]:find(key, 1, true) then
            lazy_mapping[1] = lazy_mapping[1]:gsub(key, value)
          end
        end
        return lazy_mapping
      end, plugin.keys)
    end
    return plugin
  end
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

-- The main init method, called when the import is required by lazy.nvim
---@param adapters LazyMenuAdapters
---@return table
function M.on_hook(adapters)
  local opts = get_opts(adapters.plugin)
  if not (opts and opts.to_change and type(opts.to_change) == "table" and not vim.tbl_isempty(opts.to_change)) then
    return {}
  end

  adapters.plugin.setup(remap_plugins, opts.to_change)
  adapters.which_key.setup(remap_which_key, opts.to_change)

  local lsp_to_change = reduce(opts.to_change, adapters.lsp.leaders())
  if not vim.tbl_isempty(lsp_to_change) then
    adapters.lsp.setup(remap_lsp, lsp_to_change)
  end

  local keymaps_to_change = reduce(opts.to_change, adapters.keymaps.leaders())
  if not vim.tbl_isempty(keymaps_to_change) then
    adapters.keymaps.setup(remap_keymaps, keymaps_to_change)
  end

  -- All code is injected, return a dummy spec:
  return {}
end

return M
