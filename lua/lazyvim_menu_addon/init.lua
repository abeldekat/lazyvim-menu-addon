-- TODO: Document limitations for leader c(lsp)
--
-- TODO: Extras: Vscode specific keymaps: pattern = LazyVimKeymaps, executed in config.load
--> Document: Inside vscode, when changing leader S, still a leader s s will be created

-- TODO: extras.lang.java: which-key.register in autocommand
--> document: Not possible to wrap wk.register: No way to know if keymappings are from LazyVim
--> document: When using the java extra, do not remap leader c and leader t

local Config = require("lazyvim_menu_addon.config")
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
---@param adapters LazyVimMenuAddonAdapters
---@param domain LazyVimMenuAddonDomain
---@return table
function M.on_hook(adapters, domain)
  Config.setup(adapters.plugin.get_opts())

  local opts = Config.options
  if vim.tbl_isempty(opts) then
    return {} -- Return early with a dummy spec
  end

  adapters.plugin.inject(domain.plugin.change) -- plugin.keys and plugin.opts: Parsing the spec
  adapters.keymaps.inject(domain.keymaps.change) -- lazyvim.config.keymaps.lua on VeryLazy
  if has_leader_for_lsp() then
    adapters.lsp.inject(domain.lsp.change) -- lazyvim.plugins.lsp.keymaps: Attaching to a buffer
  end

  return {} -- All code is injected, return a dummy spec
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
