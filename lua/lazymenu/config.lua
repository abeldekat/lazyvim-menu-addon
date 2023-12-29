local M = {}

---@class LazyMenuOptions
local defaults = {
  ---@type table<string,string>
  to_change = {
    -- Examples:
    --
    -- TODO: tabs?
    --
    -- b = "B", -- buffer
    -- c = "C", -- code
    -- f = "F", -- file/find
    -- g = "G", -- git
    -- q = "Q", -- quit/session
    -- s = "S", -- search
    -- u = "U", -- ui
    -- w = "W", -- window
    -- x = "X", -- diagnostics/quickfix
  },
}

---@param opts_supplied LazyMenuOptions
---@return table
M.setup = function(opts_supplied)
  ---@class LazyMenuOptions
  local result = vim.tbl_deep_extend("force", defaults, opts_supplied or {}) or {}
  if not (result.to_change and type(result.to_change) == "table" and not vim.tbl_isempty(result.to_change)) then
    return {}
  end

  local to_change_transformed = {}
  for key, value in pairs(result.to_change) do
    to_change_transformed["<leader>" .. key] = "<leader>" .. value
  end
  result.to_change = to_change_transformed
  return result
end

return M
