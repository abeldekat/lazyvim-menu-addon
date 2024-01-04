local M = {}

---@class LazyVimMenuAddonConfig
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

  -- Hook into lsp keymaps when leaders_to_change contains leaders used in lspconfig:
  leaders_in_lspconfig = { "<leader>c" }, -- on attach

  -- Hook into plugin.opts for certain plugins:
  keys_in_opts = {
    ["which-key.nvim"] = {
      property = "defaults", -- contains a table with keys
    },
    ["gitsigns.nvim"] = {
      property = "on_attach", -- contains a function with keys for leader g
    },
  },
}

---@type LazyVimMenuAddonConfig
M.options = {}

---@param opts_supplied LazyVimMenuAddonConfig
M.setup = function(opts_supplied)
  ---@class LazyVimMenuAddonConfig
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
