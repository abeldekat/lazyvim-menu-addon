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

## Example Inventory for `leader` c

### LazyVim standard menu items

- `ca`-"Code Action": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cA`-"Source Action": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cd`-"Line Diagnostics": *generic key* in `lazyvim.config.keymaps`
- `cf`-"Format": *generic key* in `lazyvim.config.keymaps`
- `cF`-"Format Injected Langs": `conform.nvim` in `lazyvim.plugins.format`
- `cl`-"Lsp Info": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cm`-"Mason": `mason.nvim` in `lazyvim.plugin.lsp`
- `cr`-"Rename": `mason.nvim` in `lazyvim.plugin.lsp`

### Menu description in `which-key.nvim`

```lua
{
  defaults = {
    -- key descriptions
    ["<leader>c"] = "+coding"
    -- more key descriptions
  }
}
```

### Adding `extras.langs`

For example: typescript

- `co`-"Organize Imports": `nvim-lspconfig` in `lazyvim.plugins.extras.lang.typescript`
- `cR`-"Remove Unused Imports": `nvim-lspconfig` in `lazyvim.plugins.extras.lang.typescript`
