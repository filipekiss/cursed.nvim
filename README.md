# cursed.nvim

## Install

### Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```vim
require("lazy").setup({
    {
        "filipekiss/cursed.nvim",
        config = true
    }
})
```

This will setup cursed with the default options.

## Usage

This plugins add two new User autocmds `CursedStart` and `CursedStop`. For
example, you can use to show `cursorline` only when the cursor has been stopped
for a while:

```lua
-- somewhere in your init.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
autocmd({ "WinEnter" }, {
    group = augroup("CursedCursorLine", { clear = true})
    pattern = "*",
    command = "set cursorline"
})

autocmd("User", {
    group = augroup("CursedCursorLine")
    pattern = "CursedStart",
    command = "set nocursorline"
})

autocmd("User", {
    group = augroup("CursedCursorLine")
    pattern = "CursedStop",
    command = "set cursorline"
})
```

If you have [nvim-blame-line][blameline], for example, you may do something like this:

```lua
-- somewhere in your init.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
autocmd("User", {
    group = augroup("CursedBlameLine")
    pattern = "CursedStop",
    command = "SingleBlameLine"
})
```

And the blame will appear after the timer runs out.

(Although if you're using nvim-blame-line you should check [gitsigns.nvim][gitsigns] which
does this — and much more — and it's written in Lua)


## Configuration

You can configure cursed by passing an object to the `setup` method. 

Using lazy.nvim:

```lua
require("lazy").setup({
    {
        "filipekiss/cursed.nvim",
        opts = {
            delay = 1000, -- set a custom delay, in ms. if not set, cursed uses vim.o.updatetime
            smart_cursorline = false, -- if true, this sets up the cursorline example from the beginning. defaults to false
        }
        config = true
    }
})
```

Or manually: 

```lua
require("cursed").setup({ delay = 1000, smart_cursorline = true })
```

#### `b:cursed_disabled`

You can set a `cursed_disabled` variable in any buffer to disable the events for the current buffer.

---

**cursed.nvim** © 2023+, Filipe Kiss Released under the [MIT] License.<br>
Authored and maintained by Filipe Kiss.

> GitHub [@filipekiss](https://github.com/filipekiss) &nbsp;&middot;&nbsp;
> Twitter [@filipekiss](https://twitter.com/filipekiss)

[mit]: http://mit-license.org/
[blameline]: https://github.com/tveskag/nvim-blame-line
[gitsigns]: https://github.com/lewis6991/gitsigns.nvim
