--[[
Rename leader c to leader C is special:
--> Mason: regular 
--> Format Injected Langs: regular
--> LSP:
  The keys are created on_attach:
  source action, code action, lsp info, rename
--> Keymaps.lua: Format and Line diagnostics

--]]
local M = {}

---@param adapter LazyMenuPluginAdapter
---@return LazyMenuOptions
local function get_opts(adapter)
  local opts = adapter.get_opts()
  opts = require("lazymenu.config").setup(opts)
  return opts
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

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_cb fun(_, plugin:LazyPlugin, results?:string[])
---@param to_change table<string,string>
local function remap(add_cb, to_change)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results)
    local fragment_has_keys = plugin and type(plugin) == "table" and plugin.keys and type(plugin.keys) == "table"
    plugin = add_cb(_, plugin, results) -- add and merge the fragment

    if fragment_has_keys and plugin._.module and plugin._.module:find("lazyvim", 1, true) then
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

---@param to_change table<string,string>
---@param leaders string[]
---@return string[]
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

-- The main init method, called when the import is required by lazy.nvim
---@param plugin_adapter LazyMenuPluginAdapter
---@param lsp_adapter LazyMenuLspAdapter
---@param keymaps_adapter LazyMenuKeymapsAdapter
function M.on_hook(plugin_adapter, lsp_adapter, keymaps_adapter)
  local opts = get_opts(plugin_adapter)
  if not opts or vim.tbl_isempty(opts) then
    return {}
  end

  plugin_adapter.setup(remap, opts.to_change)

  local lsp_to_change = reduce(opts.to_change, lsp_adapter.leaders())
  if not vim.tbl_isempty(lsp_to_change) then
    lsp_adapter.setup(remap_lsp, lsp_to_change)
  end

  local keymaps_to_change = reduce(opts.to_change, keymaps_adapter.leaders())
  if not vim.tbl_isempty(keymaps_to_change) then
    keymaps_adapter.setup(remap_keymaps, keymaps_to_change)
  end

  return {}
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
