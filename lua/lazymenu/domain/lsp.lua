local Utils = require("lazymenu.domain.utils")
---@class LazyMenuLspDomain
local M = {}

-- NOTE: LazyVim defines lsp keymapping in LazyKeysSpec format
--
-- Remaps keys in LazyVim's lsp plugins definitions after the plugin has been added
-- Is activated when LazyVim is loaded
---@param adapter_cb fun(spec?:(string|LazyKeysSpec)[])
function M.change(adapter_cb)
  -- See lazy.core.handler.keys.resolve
  ---@param spec? (string|LazyKeysSpec)[]
  return function(spec)
    if spec and type(spec) == "table" then
      spec = vim.tbl_map(function(spec_item)
        spec_item[1] = Utils.change_when_matched(spec_item[1])
        return spec_item
      end, spec)
    end
    return adapter_cb(spec)
  end
end

return M
