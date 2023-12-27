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

local function get_opts(adapter)
  local opts = adapter.get_opts()
  opts = require("lazymenu.config").setup(opts)
  return opts
end

local function remap_lsp_callback(mapping)
  -- see lazy.core.handler.keys.resolve
  -- the function is used after LazyVim has been loaded
  ---@param spec? (string|LazyKeysSpec)[]
  return function(spec)
    if spec and type(spec) == "table" then
      spec = vim.tbl_map(function(spec_item)
        if spec_item[1]:find(mapping[1], 1, true) then
          spec_item[1] = spec_item[1]:gsub(mapping[1], mapping[2])
        end
        return spec_item
      end, spec)
    end
    return spec
  end
end

local function remap_callback(opts)
  return function(_, plugin)
    -- only remap keys defined in lazyvim plugin definitions
    if not (plugin and plugin._.module and plugin._.module:find("lazyvim", 1, true)) then
      return
    end

    local remap = false
    local new_keys = vim.tbl_map(function(lazy_mapping)
      for _, mapping in ipairs(opts.mappings) do
        if lazy_mapping[1]:find(mapping[1], 1, true) then
          remap = true
          lazy_mapping[1] = lazy_mapping[1]:gsub(mapping[1], mapping[2])
        end
      end
      return lazy_mapping
    end, plugin.keys)

    if remap then
      plugin.keys = new_keys
    end
  end
end

local function is_remap_candidate_callback(plugin_fragment)
  return plugin_fragment
    and type(plugin_fragment) == "table"
    and plugin_fragment.keys
    and type(plugin_fragment.keys) == "table"
end

function M.on_hook(plugin_adapter, lsp_adapter, keymaps_adapter)
  local opts = get_opts(plugin_adapter)
  if not opts or vim.tbl_isempty(opts) then
    return {}
  end

  plugin_adapter.setup(is_remap_candidate_callback, remap_callback(opts))

  for _, mapping in ipairs(opts.mappings) do
    if mapping[1] == opts.leader_c then
      lsp_adapter.setup(remap_lsp_callback(mapping))
      keymaps_adapter.setup(mapping)
    end
  end

  return {}
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
