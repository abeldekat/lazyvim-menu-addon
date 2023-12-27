--[[
inversion of control pattern

Adapters:
Provide a central place in the code where lazy.nvim is used
Provide a central place in the code where LazyVim is used

Making sure the integration works -> see e2e_spec.lua
Making sure lazymenu works -> see unit test specs
--]]

local plugin_adapter = require("lazymenu.plugin_adapter")
local lsp_adapter = require("lazymenu.lsp_adapter")
local keymaps_adapter = require("lazymenu.keymaps_adapter")
return require("lazymenu").on_hook(plugin_adapter, lsp_adapter, keymaps_adapter)
