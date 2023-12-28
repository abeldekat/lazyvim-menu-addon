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
local function remap_keymaps(remap_keymaps_cb, mappings)
  -- See lazyvim.util.init.safe_keymap_set
  return function(mode, lhs, rhs, opts)
    for _, mapping in ipairs(mappings) do
      if lhs:find(mapping[1], 1, true) then
        lhs = lhs:gsub(mapping[1], mapping[2])
      end
    end
    remap_keymaps_cb(mode, lhs, rhs, opts)
  end
end

-- NOTE: LazyVim defines lsp keymapping in LazyKeysSpec format
--
-- Remaps keys in LazyVim's lsp plugins definitions after the plugin has been added
-- Is activated when LazyVim is loaded
---@param resolve_lsp_cb fun(spec?:(string|LazyKeysSpec)[])
---@param mappings string[]
local function remap_lsp(resolve_lsp_cb, mappings)
  -- See lazy.core.handler.keys.resolve
  ---@param spec? (string|LazyKeysSpec)[]
  return function(spec)
    if spec and type(spec) == "table" then
      spec = vim.tbl_map(function(spec_item)
        for _, mapping in ipairs(mappings) do
          if spec_item[1]:find(mapping[1], 1, true) then
            spec_item[1] = spec_item[1]:gsub(mapping[1], mapping[2])
          end
        end
        return spec_item
      end, spec)
    end
    return resolve_lsp_cb(spec)
  end
end

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_fragment_cb fun(_, plugin:LazyPlugin, results?:string[])
---@param mappings string[]
local function remap(add_fragment_cb, mappings)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results)
    local fragment_has_keys = plugin and type(plugin) == "table" and plugin.keys and type(plugin.keys) == "table"
    plugin = add_fragment_cb(_, plugin, results) -- add and merge the fragment

    if fragment_has_keys and plugin._.module and plugin._.module:find("lazyvim", 1, true) then
      local has_remap = false
      local new_keys = vim.tbl_map(function(lazy_mapping)
        for _, mapping in ipairs(mappings) do
          if lazy_mapping[1]:find(mapping[1], 1, true) then
            has_remap = true
            lazy_mapping[1] = lazy_mapping[1]:gsub(mapping[1], mapping[2])
          end
        end
        return lazy_mapping
      end, plugin.keys)
      -- vim.print("Remapping: " .. plugin.name .. " " .. vim.inspect(has_remap))
      plugin.keys = has_remap and new_keys or plugin.keys
    end
    return plugin
  end
end

---@param mappings string[]
---@param leaders string[]
---@return string[]
local function reduce(mappings, leaders)
  return vim.tbl_map(function(mapping)
    for _, leader in ipairs(leaders) do
      if mapping[1] == leader then
        return mapping
      end
    end
  end, mappings)
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

  plugin_adapter.setup(remap, opts.mappings)

  local lsp_mappings = reduce(opts.mappings, lsp_adapter.leaders())
  if not vim.tbl_isempty(lsp_mappings) then
    lsp_adapter.setup(remap_lsp, lsp_mappings)
  end

  local keymaps_mappings = reduce(opts.mappings, keymaps_adapter.leaders())
  if not vim.tbl_isempty(keymaps_mappings) then
    keymaps_adapter.setup(remap_keymaps, keymaps_mappings)
  end

  return {}
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
