# githead.yazi

Git status header for yazi inspired by [powerlevel10k](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#what-do-different-symbols-in-git-status-mean).

![preview](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview.png)

## Requirements

- yazi version >= 0.3.0
- Font with symbol support. For example [Nerd Fonts](https://www.nerdfonts.com/).

## Installation

```sh
ya pack -a llanosrocas/githead
```

Or manually copy `init.lua` to the `~/.config/yazi/plugins/githead.yazi/init.lua`

## Usage

Add this to your `~/.config/yazi/init.lua`:

```lua
require("githead"):setup()
```

Read more about indicators [here](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#what-do-different-symbols-in-git-status-mean).

Optionally, configure header:

```lua
require("githead"):setup({
  show_branch = true,
  branch_color = "blue",
  branch_symbol = "",
  branch_borders = "()",

  show_stashes = true,
  stashes_color = "bright magenta",
  stashes_symbol = "$",

  show_staged = true,
  staged_color = "bright yellow",
  staged_symbol = "+",

  show_unstaged = true,
  unstaged_color = "bright yellow",
  unstaged_symbol = "!",

  show_untracked = true,
  untracked_color = "blue",
  untracked_symbol = "?",
})
```

## Features

The goal is to use minimum amount of shell commands.

```shell
git status --ignore-submodules=dirty --branch --show-stash
```

This command provides information about branches, stashes, staged files, unstaged files, untracked files, and other statistics.

## Credits

- [yazi source code](https://github.com/sxyazi/yazi)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
