-- TODO: Document limitations for leader c(lsp) or consider decorating lspconfig.init
-- TODO: lsp consider wrapping vim.keymap.set, see keymaps.lua L97
--
-- TODO: Extras: Vscode specific keymaps: pattern = LazyVimKeymaps, executed in config.load
--> Document: Inside vscode, when changing leader S, still a leader s s will be created

-- TODO: extras.lang.java: L168, which-key register: vim.api.nvim_create_autocmd("LspAttach"
--> wrap the autocommand of which-key.register. The keys are created in which-key.register!
--> nvim-jdtls: additional keymaps in opts.on_attach()

-- TODO: extras.lang.tex:         ["<localLeader>l"] = { name = "+vimtex" },

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
