local M = {}

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

---@param opts LazyMenuConfig
---@return LazyMenuPluginAdapter
function M.plugin(opts, decorators)
  -- stylua: ignore
  return {
    get_opts = function() return opts end,
    inject = function(change_cb)
      decorators["plugin"] = change_cb(function(_, plugin, _) return plugin end)
    end,
  }
end

---@return LazyMenuValuesAdapter
function M.values(decorators)
  -- stylua: ignore
  return {
    inject = function(change_cb)
      decorators["values"] = change_cb(function(plugin,_, _) return plugin.opts end)
    end,
  }
end

---@return LazyMenuLspAdapter
function M.lsp(decorators)
  return {
    inject = function(change_cb)
      decorators["lsp"] = change_cb(function() end)
    end,
  }
end

---@return LazyMenuSafeKeymapSetAdapter
function M.keymaps(decorators)
  return {
    inject = function(change_cb)
      decorators["keymaps"] = change_cb(function() end)
    end,
  }
end

-- simulate lazy.nvim parsing the spec
local function run(decorators, spec)
  for _, plugin in ipairs(spec) do
    decorators.plugin(_, plugin) -- lazy.nvim: parsing the spec
    if plugin.opts then
      plugin.opts = decorators.values(plugin, "opts", false) -- lazy.nvim: parsing the spec
    end
  end

  -- for _, plugin in ipairs(spec) do
  --   -- decorators.lsp() -- LazyVim: attaching lsp
  -- end
  -- for _, plugin in ipairs(spec) do
  --   -- decorators.keymaps() -- LazyVim: Requiring lazyvim.config.keymaps on VeryLazy
  -- end
end

-- activate lazymenu. See lazymenu.hook
---@param opts LazyMenuConfig
function M.activate(opts, spec)
  -- contains the decorated functions created in the adapters
  local decorators = {}

  ---@type LazyMenuAdapters
  local fake_adapters = {
    plugin = M.plugin(opts, decorators),
    values = M.values(decorators),
    lsp = M.lsp(decorators),
    safe_keymap_set = M.keymaps(decorators),
  }

  ---@type LazyMenuDomain
  local domain = {
    plugin = require("lazymenu.domain.plugin"),
    values = require("lazymenu.domain.values"),
    lsp = require("lazymenu.domain.lsp"),
    keymaps = require("lazymenu.domain.keymaps"),
  }

  local dummy_spec = require("lazymenu").on_hook(fake_adapters, domain)
  run(decorators, spec) -- all hooks are ready: run

  return dummy_spec
end

return M
