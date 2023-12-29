--[[
TODO: Make the lsp and keymaps leaders configurable

Example: Rename leader c to leader C:
--> Mason: from plugin
--> Format Injected Langs: from plugin
--> LSP items: The keys are created on_attach for each buffer:
  source action, code action, lsp info, rename
--> Config.keymaps.lua: Format and Line diagnostics
--> Which-key: the ["<leader>c"] = "+coding" definition in opts.defaults
--]]
local M = {}

-- The leaders that should trigger lsp remapping or keymaps remapping
-- stylua: ignore
local leaders = {
  -- The leaders containing lsp items
  lsp = { "<leader>c"},

  -- The leaders used in keymaps.lua: Only leader s is not used
  keymaps = {
    "<leader><tab>", "<leader>b", "<leader>c", "<leader>f", "<leader>g", "<leader>q",
    "<leader>u", "<leader>w", "<leader>x"
  },
}

-- Return the opts for this plugin
---@param adapter LazyMenuPluginAdapter
---@return LazyMenuOptions
local function get_opts(adapter)
  local opts = adapter.get_opts()
  opts = require("lazymenu.config").setup(opts)
  return opts
end

-- Reduce the "to_change" table to contain only leaders defined in "leaders"
---@param to_change table<string,string>
---@param leaders_to_use string[]
---@return table<string,string>
local function reduce(to_change, leaders_to_use)
  local result = {}
  for key, value in pairs(to_change) do
    for _, leader in ipairs(leaders_to_use) do
      if key == leader then
        result[key] = value
      end
    end
  end
  return result
end

-- The main init method, called when the import is required by lazy.nvim
---@param adapters LazyMenuAdapters
---@param domain LazyMenuDomain
---@return table
function M.on_hook(adapters, domain)
  local opts = get_opts(adapters.plugin)
  if vim.tbl_isempty(opts.to_change) then
    return {} -- Opt out, return a dummy spec
  end

  adapters.plugin.setup(domain.plugin.remap, opts.to_change)
  adapters.which_key.setup(domain.which_key.remap, opts.to_change)

  local lsp_to_change = reduce(opts.to_change, leaders.lsp)
  if not vim.tbl_isempty(lsp_to_change) then
    adapters.lsp.setup(domain.lsp.remap, lsp_to_change)
  end
  local keymaps_to_change = reduce(opts.to_change, leaders.keymaps)
  if not vim.tbl_isempty(keymaps_to_change) then
    adapters.keymaps.setup(domain.keymaps.remap, keymaps_to_change)
  end

  -- All code is injected, return a dummy spec
  return {}
end

-- A dummy setup method. See on_hook.
function M.setup(_) end

return M
