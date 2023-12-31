local Config = require("lazymenu.config")
---@class LazyMenuLspDomain
local M = {}

-- NOTE: LazyVim defines lsp keymapping in LazyKeysSpec format
--
-- Remaps keys in LazyVim's lsp plugins definitions after the plugin has been added
-- Is activated when LazyVim is loaded
---@param adapter_cb fun(spec?:(string|LazyKeysSpec)[])
function M.remap(adapter_cb)
  -- See lazy.core.handler.keys.resolve
  ---@param spec? (string|LazyKeysSpec)[]
  return function(spec)
    if spec and type(spec) == "table" then
      spec = vim.tbl_map(function(spec_item)
        for key, value in pairs(Config.options.leaders_to_change) do
          if spec_item[1]:find(key, 1, true) then
            spec_item[1] = spec_item[1]:gsub(key, value)
          end
        end
        return spec_item
      end, spec)
    end
    return adapter_cb(spec)
  end
end

return M
