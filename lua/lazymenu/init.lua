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

-- Remaps keys in LazyVim's lsp plugins definitions after the plugin has been added
local function remap_lsp(mapping)
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

-- Remaps keys in LazyVim's plugin definitions after the plugin has been added
---@param add_fragment_cb fun(_, plugin:LazyPlugin, results?:string[])
---@param opts LazyMenuOptions
local function remap(add_fragment_cb, opts)
  -- See lazy.core.plugins.spec.add
  ---@param plugin LazyPlugin
  ---@param results? string[]
  return function(_, plugin, results)
    local fragment_has_keys = plugin and type(plugin) == "table" and plugin.keys and type(plugin.keys) == "table"
    plugin = add_fragment_cb(_, plugin, results) -- add and merge the fragment

    if fragment_has_keys and plugin._.module and plugin._.module:find("lazyvim", 1, true) then
      local has_remap = false
      local new_keys = vim.tbl_map(function(lazy_mapping)
        for _, mapping in ipairs(opts.mappings) do
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

---@param plugin_adapter LazyMenuPluginAdapter
---@param lsp_adapter LazyMenuLspAdapter
---@param keymaps_adapter LazyMenuKeymapsAdapter
function M.on_hook(plugin_adapter, lsp_adapter, keymaps_adapter)
  local opts = get_opts(plugin_adapter)
  if not opts or vim.tbl_isempty(opts) then
    return {}
  end

  plugin_adapter.setup(remap, opts)

  for _, mapping in ipairs(opts.mappings) do
    if mapping[1] == opts.leader_c then
      lsp_adapter.setup(remap_lsp(mapping))
      keymaps_adapter.setup(mapping)
    end
  end

  return {}
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
