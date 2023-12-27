local M = {}

local defaults = {
  -- example: mappings = {{ "<leader>c", "<leader>C" }},
  mappings = {},
  leader_c = "<leader>c",
}

M.setup = function(opts_supplied)
  return vim.tbl_deep_extend("force", defaults, opts_supplied or {}) or {}
end

return M
