--[[
Inversion of control pattern

Adapters: Contains code where LazyVim and lazy.nvim are required
Domain: Contains code for the actual logic

Making sure the integration works -> see e2e_spec.lua
Making sure lazyvim_menu_addon works -> see unit test specs
--]]

-- don't use inside vscode
if vim.g.vscode then
  return {}
end

---@type LazyVimMenuAddonAdapters
local adapters = {
  plugin = require("lazyvim_menu_addon.adapters.plugin"),
  lsp = require("lazyvim_menu_addon.adapters.lsp"),
  keymaps = require("lazyvim_menu_addon.adapters.keymaps"),
}

---@type LazyVimMenuAddonDomain
local domain = {
  plugin = require("lazyvim_menu_addon.domain.plugin"),
  lsp = require("lazyvim_menu_addon.domain.lsp"),
  keymaps = require("lazyvim_menu_addon.domain.keymaps"),
}

return require("lazyvim_menu_addon").on_hook(adapters, domain)
