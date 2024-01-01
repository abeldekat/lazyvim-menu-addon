--[[
Inversion of control pattern

Adapters: Contains code where LazyVim and lazy.nvim are required
Domain: Contains code for the actual logic

Making sure the integration works -> see e2e_spec.lua
Making sure lazymenu works -> see unit test specs
--]]

---@type LazyMenuAdapters
local adapters = {
  plugin = require("lazymenu.adapters.plugin"),
  values = require("lazymenu.adapters.values"),
  lsp = require("lazymenu.adapters.lsp"),
  keymaps = require("lazymenu.adapters.keymaps"),
}

---@type LazyMenuDomain
local domain = {
  plugin = require("lazymenu.domain.plugin"),
  values = require("lazymenu.domain.values"),
  lsp = require("lazymenu.domain.lsp"),
  keymaps = require("lazymenu.domain.keymaps"),
}

return require("lazymenu").on_hook(adapters, domain)
