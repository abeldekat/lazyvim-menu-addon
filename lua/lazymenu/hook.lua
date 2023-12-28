--[[
inversion of control pattern

Adapters:
Provide a central place in the code where lazy.nvim is used
Provide a central place in the code where LazyVim is used

Making sure the integration works -> see e2e_spec.lua
Making sure lazymenu works -> see unit test specs
--]]

local plugin_adapter = require("lazymenu.adapters.plugin")
local which_key_adapter = require("lazymenu.adapters.which_key")
local lsp_adapter = require("lazymenu.adapters.lsp")
local keymaps_adapter = require("lazymenu.adapters.keymaps")

return require("lazymenu").on_hook(plugin_adapter, which_key_adapter, lsp_adapter, keymaps_adapter)
