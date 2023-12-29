--[[
inversion of control pattern

Adapters:
Provide a central place in the code where lazy.nvim is used
Provide a central place in the code where LazyVim is used

Making sure the integration works -> see e2e_spec.lua
Making sure lazymenu works -> see unit test specs
--]]

---@type LazyMenuAdapters
local adapters = {
  plugin = require("lazymenu.adapters.plugin"),
  which_key = require("lazymenu.adapters.which_key"),
  lsp = require("lazymenu.adapters.lsp"),
  keymaps = require("lazymenu.adapters.keymaps"),
}

return require("lazymenu").on_hook(adapters)
