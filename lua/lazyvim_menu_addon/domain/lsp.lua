local Utils = require("lazyvim_menu_addon.domain.utils")
---@class LazyVimMenuAddonLspDomain
local M = {}

-- Changes keys in LazyVim's nvim-lspconfig spec, on attach
-- Is activated when LazyVim is loaded
---@param adapter_cb fun(_, buffer:integer)
function M.change(adapter_cb)
  -- see lazyvim.plugins.lsp.keymaps.on_attach
  ---@param buffer integer
  return function(_, buffer) -- client
    local keymap_set_orig = vim.keymap.set

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.keymap.set = function(mode, l, r, opts) -- intercept
      keymap_set_orig(mode, Utils.change_when_matched(l), r, opts)
    end
    adapter_cb(_, buffer)
    vim.keymap.set = keymap_set_orig -- release
  end
end

return M
