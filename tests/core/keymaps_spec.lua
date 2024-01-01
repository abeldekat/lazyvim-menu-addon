local h = require("tests.unit_helpers")
local dummy_action = function() end

describe("keymaps in lazyvim.config.keymaps", function()
  local keymaps = {
    { "<leader>gg", dummy_action, { desc = "LazyVim defined" } },
    { "<leader>gG", dummy_action, { desc = "LazyVim defined" } },
  }
  it("are also changed when using safe_keymap_set", function()
    local opts = { leaders_to_change = { g = "G" } }

    vim.keymap.set({ "n" }, "<leader>gN", dummy_action, { desc = "User defined" })
    h.activate(opts, { keymaps = keymaps })
    vim.keymap.set({ "n" }, "<leader>gP", dummy_action, { desc = "User defined" })

    for _, key in ipairs({ "\\Gg", "\\GG", "\\gN", "\\gP" }) do
      assert(h.has_key(key), "Key expected: " .. key)
    end
  end)
end)
