local M = {}

---@class LazyVimMenuAddonConfigUser
local defaults = { -- the defaults exposed to the user
  -- Select the leaders to change and the new value to use:
  ---@type table<string,string>
  leaders_to_change = {
    -- Examples:
    --
    -- ["<tab>"] = "T", -- tabs
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

---@class LazyVimMenuAddonConfig:LazyVimMenuAddonConfigUser
M.options = {
  leaders_in_lspconfig = { "<leader>c" }, -- current leader for nvim-lspconfig
  change_in_opts = { -- Hook into plugin.opts for certain plugins:
    ["which-key.nvim"] = "defaults", -- a table with keys and menu descriptions
    ["gitsigns.nvim"] = "on_attach", -- a function defining keys for leader g
    -- extras:
    -- ["edgy.nvim"] = "keys", -- a table with keys(no leaders) the user can override
  },
}

---@param opts LazyVimMenuAddonConfigUser
M.setup = function(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts)

  M.options = vim.tbl_deep_extend("force", M.options, opts or {}) or {}
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
