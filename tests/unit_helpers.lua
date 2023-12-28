local M = {}

function M.all_keys(spec)
  local result = {}
  for _, plugin in ipairs(spec) do
    for _, key in ipairs(plugin.keys) do
      table.insert(result, key[1])
    end
  end
  return result
end

---@param opts LazyMenuOptions
---@return LazyMenuPluginAdapter
function M.fake_plugin_adapter(opts, spec)
  return {
    get_opts = function()
      return opts
    end,
    setup = function(remap_cb, to_change)
      local add = remap_cb(function(_, plugin, _)
        return plugin
      end, to_change)
      for _, plugin in ipairs(spec) do
        add(_, plugin)
      end
    end,
  }
end

---@return LazyMenuWhichKeyAdapter
function M.fake_which_key_adapter()
  return {
    setup = function(remap_cb, to_change)
      remap_cb(function() end, to_change)
    end,
  }
end

---@return LazyMenuLspAdapter
function M.fake_lsp_adapter()
  return {
    leaders = function()
      return {}
    end,
    setup = function(remap_cb, to_change)
      remap_cb(function() end, to_change)
    end,
  }
end

---@return LazyMenuKeymapsAdapter
function M.fake_keymaps_adapter()
  return {
    leaders = function()
      return {}
    end,
    setup = function(remap_cb, to_change)
      remap_cb(function() end, to_change)
    end,
  }
end

-- run lazymenu. See lazymenu.hook
-- simulate lazy.nvim parsing the spec
---@param opts LazyMenuOptions
function M.activate(opts, spec)
  local plugin = M.fake_plugin_adapter(opts, spec)
  local which_key = M.fake_which_key_adapter()
  local lsp = M.fake_lsp_adapter()
  local keymappings = M.fake_keymaps_adapter()

  return require("lazymenu").on_hook(plugin, which_key, lsp, keymappings)
end

return M
