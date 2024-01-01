-- TODO: rename safe keymaps set adapter

local Config = require("lazymenu.config")
local M = {}

-- The user wants to remap a leader containing lsp mappings
local function has_leader_for_lsp()
  for _, leader in ipairs(Config.options.leaders_in_lspconfig) do
    if Config.options.leaders_to_change[leader] then
      return true
    end
  end
  return false
end

-- The main init method, called when the import is required by lazy.nvim
---@param adapters LazyMenuAdapters
---@param domain LazyMenuDomain
---@return table
function M.on_hook(adapters, domain)
  Config.setup(adapters.plugin.get_opts())

  local opts = Config.options
  if vim.tbl_isempty(opts) then
    return {} -- Return early with a dummy spec
  end

  adapters.plugin.inject(domain.plugin.change) -- plugin.keys
  adapters.values.inject(domain.values.change) -- plugin.opts
  adapters.safe_keymap_set.inject(domain.keymaps.change) -- lazyvim.config.keymaps.lua
  if has_leader_for_lsp() then
    adapters.lsp.inject(domain.lsp.change) -- lazyvim.plugins.lsp.keymaps
  end

  return {} -- All code is injected, return a dummy spec
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
