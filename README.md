# lazyvim-menu-addon

Facilitates changing the top level leader menus created by `LazyVim`

Work in progress... *Almost* done.

```lua
    -- Example: move all menu-items defined in LazyVim for leader f to leader F
    { 
      "abeldekat/lazyvim-menu-addon",
      import = "lazyvim_menu_addon.hook",
      opts = { leaders_to_change = { f = "F" } } 
    },
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
```

## TODO

## NOTES

Example: Rename leader c to leader C:

- `Mason`: keys from plugin definition
- `Format Injected Langs`: keys from plugin definition
- `LSP related`: The keys are created on_attach for each buffer:
  source action, code action, lsp info, rename
- `lazyvim.config.keymaps`: Format and Line diagnostics
- `Which-key`: the `["<leader>c"]` = "+coding" definition in its opts.defaults
