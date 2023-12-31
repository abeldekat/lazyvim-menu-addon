local M = {}

---@class LazyMenuConfig
local defaults = {
  -- Select the leaders to change and the new value to use:
  ---@type table<string,string>
  leaders_to_change = {
    -- Examples:
    --
    -- TODO: tabs?
    --
    -- ["<tabs"] = "T", -- tabs
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

  -- Only hook into lsp's keymap attach when leaders_to_change has the leaders for lsp:
  lsp = { "<leader>c" }, -- on attach

  -- Only hook into plugin.opts for certain plugins:
  keys_in_opts = {
    ["which-key.nvim"] = {
      property = "defaults", -- contains a table with keys
      type = "table",
    },
    ["gitsigns.nvim"] = {
      property = "on_attach", -- contains a function with keys for leader g
      type = "function",
    },
  },
}

---@type LazyMenuConfig
M.options = {}

---@param opts_supplied LazyMenuConfig
M.setup = function(opts_supplied)
  ---@class LazyMenuConfig
  M.options = vim.tbl_deep_extend("force", defaults, opts_supplied or {}) or {}
  local to_change = M.options.leaders_to_change
  if not (to_change and type(to_change) == "table" and not vim.tbl_isempty(to_change)) then
    return {}
  end

  local to_change_transformed = {}
  for key, value in pairs(to_change) do
    to_change_transformed["<leader>" .. key] = "<leader>" .. value
  end
  M.options.leaders_to_change = to_change_transformed
end

return M
