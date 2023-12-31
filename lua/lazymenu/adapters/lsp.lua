Utils = require("lazymenu.adapters.utils")

---@class LazyMenuLspAdapter
local M = {}

---@param remap_cb fun(resolve_lsp_cb:fun())
function M.inject(remap_cb)
  Utils.on_load("LazyVim", function()
    local LazyVimKeys = require("lazyvim.plugins.lsp.keymaps")
    local on_attach = LazyVimKeys.on_attach

    ---@diagnostic disable-next-line: duplicate-set-field
    LazyVimKeys.on_attach = function(_, buffer)
      local LazyKeys = require("lazy.core.handler.keys")
      local resolve = LazyKeys.resolve
      local resolve_decorated = remap_cb(resolve)

      ---@diagnostic disable-next-line: duplicate-set-field
      LazyKeys.resolve = function(spec) -- inject when attaching
        return resolve_decorated(spec)
      end
      on_attach(_, buffer)
      LazyKeys.resolve = resolve -- restore when done
    end
  end)
end

return M
