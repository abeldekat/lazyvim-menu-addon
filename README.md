# lazymenu.nvim
Facilitates remapping of LazyVim's leader menus

WIP

```lua

    -- Example: move all menu-items defined in LazyVim for leader f to leader F
    { "abeldekat/lazymenu.nvim", import = "lazymenu.hook", opts = { to_change = { f = "F" } } },
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
```
