---@class LazyVimMenuAddonLspAdapter
local M = {}

---@param change_cb fun(_):fun(_, buffer:integer)
function M.inject(change_cb)
  require("lazyvim_menu_addon.adapters.utils").on_load("LazyVim", function()
    local LazyVimKeys = require("lazyvim.plugins.lsp.keymaps")
    local on_attach_decorated = change_cb(LazyVimKeys.on_attach)

    ---@diagnostic disable-next-line: duplicate-set-field
    LazyVimKeys.on_attach = function(client, buffer)
      on_attach_decorated(client, buffer)
    end
  end)
end

return M
