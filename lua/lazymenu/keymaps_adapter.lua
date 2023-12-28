Utils = require("lazymenu.utils")
---@class LazyMenuKeymapsAdapter
local M = {}

function M.setup(mapping)
  Utils.on_load("LazyVim", function()
    local Util = require("lazyvim.util")
    local map = Util.safe_keymap_set

    ---@diagnostic disable-next-line: duplicate-set-field
    Util.safe_keymap_set = function(mode, lhs, rhs, opts)
      if lhs:find(mapping[1], 1, true) then
        lhs = lhs:gsub(mapping[1], mapping[2])
      end
      map(mode, lhs, rhs, opts)
    end
  end)
end
return M
