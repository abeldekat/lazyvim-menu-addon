# lazyvim-menu-addon

**Update** 20240329: This repository is archived. 


**lazyvim-menu-addon** is an add-on for [LazyVim].

[LazyVim] is a Neovim setup powered by [lazy.nvim]
to make it easy to customize and extend your config.

**Use-case**:

The user wishes to change a top-level leader menu supplied by [LazyVim],
in order to use the corresponding leader key for something else.

The effort required to do so manually can be considerable.

For example, when changing `leader c` into `leader C`,
each individual [`leader c`](#example-leader-c-in-lazyvim) key
needs to be taken into consideration.

This addon will perform the changes automatically.

## Demo

<https://github.com/abeldekat/lazyvim-menu-addon/assets/58370433/b0dbac52-acfb-4263-b56c-60cb4400b724>

## Features

Leader keys will be changed when defined in:

- plugin definitions
- which-key menu descriptions
- lazyvim.config.keymaps
- nvim-lspconfig

Leader mappings defined by the user will **not** be modified.

The addon is designed to change a leader key
into an **available** new leader key.

A decline in performance is not expected.

## Installation

```lua
{ -- insert before LazyVim!
  "abeldekat/lazyvim-menu-addon",
  version = "*",
  import = "lazyvim_menu_addon.hook",
  opts = { leaders_to_change = { f = "F", w = "W" } } -- for example...
},
-- add LazyVim and import its plugins
{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
```

*Note*:

The addon must be inserted before the line that adds LazyVim
in the [starter template].

## Examples

### Change `leader f` for harpoon

```lua
{ 
  "abeldekat/lazyvim-menu-addon",
  import = "lazyvim_menu_addon.hook",
  opts = { leaders_to_change = { f = "F" } }
},
-- add LazyVim and import its plugins
{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
{
  name = "ThePrimeagen/harpoon.nvim",
  keys = { 
    { 
      "<leader>f",
      function() vim.print("Harpoon UI") end,
      desc = "Harpoon UI on leader f" }
    },
},
```

### Change `leader q` and `leader w`

Map keys for `leader q` to quit and `leader w` to write.

```lua
{ 
  "abeldekat/lazyvim-menu-addon",
  import = "lazyvim_menu_addon.hook",
  opts = { leaders_to_change = { q = "Q", w = "W" } }
},
-- add LazyVim and import its plugins
{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
--
-- In your keymaps.lua, using a simple map function for vim.keymap.set:
--
-- leader q now available:
-- map("n", "<leader>q", "<cmd>q<cr>", { desc = "[Q]uit" })
-- leader w now available:
-- map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "[W]rite" })
```

## Configuration

```lua
{
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
```

## Current limitations

### nvim-lspconfig

The algorithm changing keys for `nvim-lspconfig` does not differentiate
between keys defined in `LazyVim`'s [lsp keys] and keys defined by the user.

Consequently, when changing `leader c`,
any `leader c` defined by the user
targeting `nvim-lspconfig` will be changed as well.

The user can use `leader c` for other actions.

Changing keys for the lsp is explained in the [docs]:

- [lsp keymaps](https://www.lazyvim.org/configuration/keymaps#lsp-keymaps)
- [customizing lsp keymaps](https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps)

### vscode extra

The [vscode extra] defines a key for `leader s` that is not intercepted.
When using vscode, please do not change `leader s` using this addon.

### java extra

The [java extra] is the only extra in `extras.lang`
using `which-key.register` to map actual keys.
That method is difficult to reliably intercept.
When using the java extra,
please do not change `leader c` and `leader t` using this addon.

## Adapters

This addon injects code into the following methods:

- [`lazy.nvim plugin add`](https://github.com/folke/lazy.nvim/blob/96584866b9c5e998cbae300594d0ccfd0c464627/lua/lazy/core/plugin.lua#L57)
- [`LazyVim lsp keymaps`](https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/plugins/lsp/keymaps.lua#L15)
- [`LazyVim safe-keymap-set`](https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/util/init.lua#L149)

## Example: Leader c in LazyVim

An overview of all `<leader> c` occurrences in the current codebase.

### LazyVim core

- `ca`-"Code Action": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cA`-"Source Action": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cd`-"Line Diagnostics": *generic key* in `lazyvim.config.keymaps`
- `cf`-"Format": *generic key* in `lazyvim.config.keymaps`
- `cF`-"Format Injected Langs": `conform.nvim` in `lazyvim.plugins.format`
- `cl`-"Lsp Info": `nvim-lspconfig` in `lazyvim.plugin.lsp.keymaps`
- `cm`-"Mason": `mason.nvim` in `lazyvim.plugin.lsp`
- `cr`-"Rename": `mason.nvim` in `lazyvim.plugin.lsp`

### `which-key.nvim`

```lua
{
  defaults = {
    -- key descriptions
    ["<leader>c"] = "+coding"
    -- more key descriptions
  }
}
```

### `extras.lang`

For example: typescript

- `co`-"Organize Imports": `nvim-lspconfig` in `lazyvim.plugins.extras.lang.typescript`
- `cR`-"Remove Unused Imports": `nvim-lspconfig` in `lazyvim.plugins.extras.lang.typescript`

## Alternatives

### Manually

This is the current approach.

[LazyVim] provides a lot of flexibility when mapping individual keys.
However, when the user wants to change a top-level menu,
in order to use that `leader key` for something else,
the number of changes to perform can be considerable.

*Note*:

I presume that the use-case this addon addresses is not that common.

### Builtin to LazyVim

See this [feature request]:
> feature: configurable single source of truth for keymaps

The solution proposed in this request implicates a lot of changes to the codebase.
Each key mapping would require a string operation on the leader part
and the actual key.

```lua
-- Feature request, the suggested solution:
{
  "PrefixCode" = "<leader>c",
  "KeymapMason" = "%PrefixCode%m",
  "KeymapFormatInjected" = "%PrefixCode%F",
  ...
}

-- Current codebase: mason.nvim in lazyvim.plugins.lsp:
{

  "williamboman/mason.nvim",
  -- spec
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  -- more of the spec
}
```

**Opinion**:

*Pros*:

**All** keys would be configurable from one central location.

*Cons*:

The keys in the current codebase are readable on first sight.
No need to first find out what the prefix is mapped to.
Also, having a definition file covering all keys
reduces the independence of the modules in the codebase.

*Purpose of the addon*:

This addon provides an alternative approach
to the proposed solution in the [feature request].

The user is expected to change individual keys as usual.
The knowledge gained by doing so is very valuable.
After all, [LazyVim] is intended to customize and extend *your* config.

That said, this addon can be helpful when changing a top-level leader menu,
with the intent to use the corresponding `leader` key for something else.

*Note*:

It would be possible to incorporate the code or ideas
supplied by this addon into the codebase of [LazyVim]

## Acknowledgements

- [lazy.nvim]: The architecture, semantics and enhanced possibilities.
- [LazyVim]: The concept of a plugin as a collection of other plugins.

[lazy.nvim]: https://github.com/folke/lazy.nvim
[LazyVim]: https://github.com/LazyVim/LazyVim
[docs]: https://www.lazyvim.org/
[starter template]: https://github.com/LazyVim/starter/blob/92b2689e6f11004e65376e84912e61b9e6c58827/lua/config/lazy.lua#L12
[lsp keys]: https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/plugins/lsp/keymaps.lua#L15
[vscode extra]: https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/plugins/extras/vscode.lua#L31
[java extra]: https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/plugins/extras/lang/java.lua#L174
[feature request]: https://github.com/LazyVim/LazyVim/issues/2193
