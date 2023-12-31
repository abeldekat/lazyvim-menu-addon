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

---@param opts LazyMenuOptions
---@return LazyMenuPluginAdapter
function M.plugin(opts, decorators)
  -- stylua: ignore
  return {
    get_opts = function() return opts end,
    inject = function(remap_cb, to_change)
      local add_decorated = remap_cb(function(_, plugin, _) return plugin end, to_change)
      decorators["plugin"] = add_decorated
    end,
  }
end

---@return LazyMenuLspAdapter
function M.lsp(decorators)
  return {
    inject = function(remap_cb, to_change)
      local resolve_decorated = remap_cb(function() end, to_change)
      decorators["lsp"] = resolve_decorated
    end,
  }
end

---@return LazyMenuSafeKeymapSetAdapter
function M.safe_keymap_set(decorators)
  return {
    inject = function(remap_cb, to_change)
      local safe_keymap_set_decorated = remap_cb(function() end, to_change)
      decorators["keymaps"] = safe_keymap_set_decorated
    end,
  }
end

-- simulate lazy.nvim parsing the spec
local function run(decorators, spec)
  for _, plugin in ipairs(spec) do
    decorators.plugin(_, plugin) -- lazy.nvim: parsing the spec
  end

  -- for _, plugin in ipairs(spec) do
  --   -- decorators.lsp() -- LazyVim: attaching lsp
  -- end
  -- for _, plugin in ipairs(spec) do
  --   -- decorators.keymaps() -- LazyVim: Requiring lazyvim.config.keymaps on VeryLazy
  -- end
end

-- activate lazymenu. See lazymenu.hook
---@param opts LazyMenuOptions
function M.activate(opts, spec)
  -- contains the decorated functions created in the adapters
  local decorators = {}

  ---@type LazyMenuAdapters
  local fake_adapters = {
    plugin = M.plugin(opts, decorators),
    lsp = M.lsp(decorators),
    safe_keymap_set = M.safe_keymap_set(decorators),
  }

  ---@type LazyMenuDomain
  local domain = {
    plugin = require("lazymenu.domain.plugin"),
    lsp = require("lazymenu.domain.lsp"),
    keymaps = require("lazymenu.domain.keymaps"),
  }

  local dummy_spec = require("lazymenu").on_hook(fake_adapters, domain)
  run(decorators, spec) -- all hooks are ready: run

  return dummy_spec
end

return M
