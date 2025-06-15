# githead.yazi

Git status header for yazi inspired by [powerlevel10k](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#what-do-different-symbols-in-git-status-mean).

![preview](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview.png)
![preview](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-2.png)

All supported features are listed [here](#features)

## Requirements

- yazi version >= [693dff2](https://github.com/sxyazi/yazi/tree/693dff25e3165e357cc9d0b94ca3f2b176741a36).
- Font with symbol support. For example [Nerd Fonts](https://www.nerdfonts.com/).

## Installation

```sh
ya pkg add llanosrocas/githead
```

Or manually copy `main.lua` to the `~/.config/yazi/plugins/githead.yazi/main.lua`

## Usage

Add this to your `~/.config/yazi/init.lua`:

```lua
require("githead"):setup()
```

Read more about symbols [here](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#what-do-different-symbols-in-git-status-mean).

Optionally, configure header:

```lua
require("githead"):setup({
  order = {
    "branch",
    "remote",
    "behind_ahead",
    "stashes",
    "state",
    "staged",
    "unstaged",
    "untracked",
  }

  show_branch = true,
  branch_prefix = "on",
  branch_color = "blue",
  branch_symbol = "",
  branch_borders = "()",

  show_remote = true, -- only shown if different from local branch
  remote_prefix = ":",
  remote_color = "bright magenta",

  commit_color = "bright magenta",
  commit_symbol = "@",

  show_behind_ahead = true,
  behind_color = "bright magenta",
  behind_symbol = "⇣",
  ahead_color = "bright magenta",
  ahead_symbol = "⇡",

  show_stashes = true,
  stashes_color = "bright magenta",
  stashes_symbol = "$",

  show_state = true,
  show_state_prefix = true,
  state_color = "red",
  state_symbol = "~",

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

```
/cwd on ( feature):main ⇣2⇡3 $1 rebase 1/2 ~2 +4 !1 ?5
|    |   |        ││     | |  |  |          |  |  |  |
|    |   |        ││     | |  |  |          |  |  |  └─── untracked_symbol
|    |   |        ││     | |  |  |          |  |  └────── unstaged_symbol
|    |   |        ││     | |  |  |          |  └───────── staged_symbol
|    |   |        ││     | |  |  |          └──────────── state_symbol
|    |   |        ││     | |  |  └─────────────────────── state_prefix
|    |   |        ││     | |  └────────────────────────── stashes_symbol
|    |   |        ││     | └───────────────────────────── ahead_symbol
|    |   |        ││     └─────────────────────────────── behind_symbol
|    |   |        |└───────────────────────────────────── remote_prefix
|    |   |        └────────────────────────────────────── branch_borders
|    |   └─────────────────────────────────────────────── branch_symbol
|    └─────────────────────────────────────────────────── branch_prefix
└──────────────────────────────────────────────────────── cwd
```

## Features

- [x] Current branch (or current commit if branch is not presented)
- [x] Remote branch (only if it's different from local branch)
- [x] Behind/Ahead of the remote
- [x] Stashes
- [x] States
  - [x] merge
  - [x] cherry
  - [x] rebase (+ done counter)
  - [x] revert
  - [x] bisect (only if other states are not present)
- [x] Staged
- [x] Unstaged
- [x] Untracked

### Under the hood

The goal is to use minimum amount of shell commands.

```shell
git status --ignore-submodules=dirty --branch --show-stash --ahead-behind
```

This command provides information about branches, stashes, staged files, unstaged files, untracked files, and other statistics.

## Credits

- [yazi source code](https://github.com/sxyazi/yazi)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [twio142](https://github.com/twio142/githead.yazi)
