local M = {}

---@param key string
---@param buffer? integer
function M.has_key(key, buffer)
  local keymaps = buffer and vim.api.nvim_buf_get_keymap(0, "n") or vim.api.nvim_get_keymap("n")
  for _, item in ipairs(keymaps) do
    if key == item.lhs then
      return true
    end
  end
  return false
end

--- Returns all "lhs" from each plugin.keys
--- In the unit tests, plugin.keys should be of type LazyKeysSpec[]
---@return string[]
function M.lazy_keys_result(spec)
  local result = {}
  for _, plugin in ipairs(spec) do
    if plugin.keys then
      for _, key in ipairs(plugin.keys) do
        table.insert(result, key[1])
      end
    end
  end
  return result
end

---@param opts LazyVimMenuAddonConfig
---@return LazyVimMenuAddonPluginAdapter
function M.plugin(opts, decorators)
  -- stylua: ignore
  return {
    get_opts = function() return opts end,
    inject = function(change_cb)
      decorators["plugin"] = change_cb(function(_, plugin, _) return plugin end)
    end,
  }
end

---@return LazyVimMenuAddonLspAdapter
function M.lsp(decorators)
  return {
    inject = function(change_cb)
      decorators["lsp"] = change_cb(function(spec) ---param spec? (string|LazyKeysSpec)[]
        -- for testing: simulate the result by setting the keymap
        for _, item in ipairs(spec) do
          vim.keymap.set({ "n" }, item[1], item[2], { desc = item.desc })
        end
      end)
    end,
  }
end

---@return LazyVimMenuAddonKeymapsAdapter
function M.keymaps(decorators)
  return {
    inject = function(change_cb)
      decorators["keymaps"] = change_cb(function(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, opts)
      end)
    end,
  }
end

-- Simulate activation by lazy.nvim
local function run(decorators, test_input)
  if test_input.spec then -- plugin adapter
    for _, plugin in ipairs(test_input.spec) do
      decorators.plugin(_, plugin) -- plugin
    end
  end

  if test_input.keyspec then -- lsp adapter
    decorators.lsp(test_input.keyspec)
  end

  if test_input.keymaps then -- keymaps adapter
    for _, keymap in ipairs(test_input.keymaps) do
      decorators.keymaps({ "n" }, keymap[1], keymap[2], keymap[3])
    end
  end
end

-- activate lazyvim-menu-addon. See lazyvim_menu_addon.hook
---@param opts LazyVimMenuAddonConfig
function M.activate(opts, test_input)
  -- run: contains decorated functions created in each fake_adapter.inject
  local decorators = {}

  ---@type LazyVimMenuAddonAdapters
  local fake_adapters = {
    plugin = M.plugin(opts, decorators),
    lsp = M.lsp(decorators),
    keymaps = M.keymaps(decorators),
  }

  ---@type LazyVimMenuAddonDomain
  local domain = {
    plugin = require("lazyvim_menu_addon.domain.plugin"),
    lsp = require("lazyvim_menu_addon.domain.lsp"),
    keymaps = require("lazyvim_menu_addon.domain.keymaps"),
  }

  local dummy_spec = require("lazyvim_menu_addon").on_hook(fake_adapters, domain)
  run(decorators, test_input) -- all code is injected: run

  return dummy_spec
end

return M
