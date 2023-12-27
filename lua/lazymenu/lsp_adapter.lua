Utils = require("lazymenu.utils")
local M = {}

function M.setup(remap_cb)
  Utils.on_load("LazyVim", function()
    local LazyVimKeys = require("lazyvim.plugins.lsp.keymaps")
    local on_attach = LazyVimKeys.on_attach

    ---@diagnostic disable-next-line: duplicate-set-field
    LazyVimKeys.on_attach = function(_, buffer)
      local LazyKeys = require("lazy.core.handler.keys")
      local resolve = LazyKeys.resolve

      ---@diagnostic disable-next-line: duplicate-set-field
      LazyKeys.resolve = function(spec)
        return resolve(remap_cb(spec))
      end
      on_attach(_, buffer)
      LazyKeys.resolve = resolve
    end
  end)
end

return M
