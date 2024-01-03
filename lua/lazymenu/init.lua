-- TODO: which-key: Distinguish between lazyvim and user vim opts
-- TODO: Implement "remove"
-- TODO: Document limitations for leader c(lsp) and leader g(gitsigns)
-- TODO: Rename the project to lazyvim-menu-addon

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

  adapters.plugin.inject(domain.plugin.change) -- plugin.keys: Parsing the spec
  adapters.values.inject(domain.values.change) -- plugin.opts: Loading the plugin
  adapters.keymaps.inject(domain.keymaps.change) -- lazyvim.config.keymaps.lua on VeryLazy
  if has_leader_for_lsp() then
    adapters.lsp.inject(domain.lsp.change) -- lazyvim.plugins.lsp.keymaps: Attaching to a buffer
  end

  return {} -- All code is injected, return a dummy spec
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
