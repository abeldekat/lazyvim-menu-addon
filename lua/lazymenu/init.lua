-- TODO: plugin, opts, deepextend?
local M = {}

-- Reduce the "to_change" table to contain only leaders defined in "leaders"
---@param to_change table<string,string>
---@param leaders_to_use string[]
---@return table<string,string>
local function reduce(to_change, leaders_to_use)
  local result = {}
  for key, value in pairs(to_change) do
    for _, leader in ipairs(leaders_to_use) do
      if key == leader then
        result[key] = value
      end
    end
  end
  return result
end

-- The main init method, called when the import is required by lazy.nvim
---@param adapters LazyMenuAdapters
---@param domain LazyMenuDomain
---@return table
function M.on_hook(adapters, domain)
  local Config = require("lazymenu.config")
  Config.setup(adapters.plugin.get_opts())

  local opts = Config.options
  if vim.tbl_isempty(opts) then
    return {} -- Opt out, return a dummy spec
  end

  adapters.plugin.inject(domain.plugin.remap)
  adapters.safe_keymap_set.inject(domain.keymaps.remap)

  local lsp_to_change = reduce(opts.leaders_to_change, opts.lsp)
  if not vim.tbl_isempty(lsp_to_change) then
    -- adapters.lsp.inject(domain.lsp.remap)
  end

  -- All code is injected, return a dummy spec
  return {}
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
