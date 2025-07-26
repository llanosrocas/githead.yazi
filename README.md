# githead.yazi

Git status header for yazi inspired by [powerlevel10k](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#what-do-different-symbols-in-git-status-mean).

![preview-default](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-default.png)
![preview-fullscreen](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-fullscreen.png)

All supported features are listed [here](#features). More presets are available [here](#presets).

## Requirements

- yazi version >= [917e1f5](https://github.com/sxyazi/yazi/commit/917e1f54a10445f2e25147c4b81a3c77d8233632).
- Font with symbol support. For example [Nerd Fonts](https://www.nerdfonts.com/).

## Compatibility

To keep the plugin up to date, there are two branches: `main` and `nightly`.
The `main` branch follows major yazi releases, while `nightly` is linked to specific yazi commits or changes.

This setup allows shipping stable versions on time, while giving early access to "cutting-edge" changes. See matrix below.

<details close>
<summary>Compatibility matrix</summary>

|                                  githead                                  | yazi                                                                                      |
| :-----------------------------------------------------------------------: | ----------------------------------------------------------------------------------------- |
| [v2.0.1](https://github.com/llanosrocas/githead.yazi/releases/tag/v2.0.1) | [917e1f5](https://github.com/sxyazi/yazi/commit/917e1f54a10445f2e25147c4b81a3c77d8233632) |
| [v2.0.0](https://github.com/llanosrocas/githead.yazi/releases/tag/v2.0.0) | [693dff2](https://github.com/sxyazi/yazi/commit/693dff25e3165e357cc9d0b94ca3f2b176741a36) |
| [v1.7.0](https://github.com/llanosrocas/githead.yazi/releases/tag/v1.7.0) | [693dff2](https://github.com/sxyazi/yazi/tree/693dff25e3165e357cc9d0b94ca3f2b176741a36)   |
| [v1.6.0](https://github.com/llanosrocas/githead.yazi/releases/tag/v1.6.0) | [v25.5.31](https://github.com/sxyazi/yazi/releases/tag/v25.5.31)                          |

</details>

## Installation

1. Using yazi package manager

```sh
ya pkg add llanosrocas/githead
```

_Or manually copy `main.lua` to the `~/.config/yazi/plugins/githead.yazi/main.lua`_

2. Add this line to your `~/.config/yazi/init.lua`:

```lua
require("githead"):setup()
```

## Configuration

This is default config, if you want to see copy-paste presets go to [this section](#presets).

```lua
require("githead"):setup({
  order = {
    "__spacer__",
    "branch",
    "remote",
    "__spacer__",
    "tag",
    "__spacer__",
    "commit",
    "__spacer__",
    "behind_ahead_remote",
    "__spacer__",
    "stashes",
    "__spacer__",
    "state",
    "__spacer__",
    "staged",
    "__spacer__",
    "unstaged",
    "__spacer__",
    "untracked",
  },

  show_numbers = true, -- shows staged, unstaged, untracked, stashes count

  show_branch = true,
  branch_prefix = "",
  branch_color = "blue",
  branch_symbol = "",
  branch_borders = "",

  show_remote_branch = true, -- only shown if different from local branch
  always_show_remote_branch = false, -- always show remote branch even if it the same as local branch
  always_show_remote_repo = false, -- Adds `origin/` if `always_show_remote_branch` is enabled
  remote_branch_prefix = ":",
  remote_branch_color = "bright magenta",

  show_tag = true, -- only shown if branch is not available
  always_show_tag = false,
  tag_color = "magenta",
  tag_symbol = "#",

  show_commit = true, -- only shown if branch AND tag are not available
  always_show_commit = false,
  commit_color = "bright magenta",
  commit_symbol = "@",

  show_behind_ahead_remote = true,
  behind_remote_color = "bright magenta",
  behind_remote_symbol = "⇣",
  ahead_remote_color = "bright magenta",
  ahead_remote_symbol = "⇡",

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
/cwd on ( feature):origin/main #v1.0.0 #1234567 ⇣2⇡3 $1 rebase 1/2 ~2 +4 !1 ?5
|    |   |  |     ││ |     |    |       |        | |  |  |          |  |  |  |
|    |   |  |     ││ |     |    |       |        | |  |  |          |  |  |  └─── untracked_symbol
|    |   |  |     ││ |     |    |       |        | |  |  |          |  |  └────── unstaged_symbol
|    |   |  |     ││ |     |    |       |        | |  |  |          |  └───────── staged_symbol
|    |   |  |     ││ |     |    |       |        | |  |  |          └──────────── state_symbol
|    |   |  |     ││ |     |    |       |        | |  |  └─────────────────────── state_prefix
|    |   |  |     ││ |     |    |       |        | |  └────────────────────────── stashes_symbol
|    |   |  |     ││ |     |    |       |        | └───────────────────────────── ahead_symbol
|    |   |  |     ││ |     |    |       |        └─────────────────────────────── behind_symbol
|    |   |  |     ││ |     |    |       └──────────────────────────────────────── commit_symbol
|    |   |  |     ││ |     |    └──────────────────────────────────────────────── tag_symbol
|    |   |  |     ││ |     └───────────────────────────────────────────────────── remote_branch
|    |   |  |     ││ └─────────────────────────────────────────────────────────── remote_repo
|    |   |  |     |└───────────────────────────────────────────────────────────── remote_branch_prefix
|    |   |  |     └────────────────────────────────────────────────────────────── branch_borders
|    |   |  └──────────────────────────────────────────────────────────────────── branch
|    |   └─────────────────────────────────────────────────────────────────────── branch_symbol
|    └─────────────────────────────────────────────────────────────────────────── branch_prefix
└──────────────────────────────────────────────────────────────────────────────── cwd
```

## Presets

- v1 default (My config)

  ![preview-fav](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-fav.png)

  <details>
  <summary>Config</summary>

  ```lua
  require("githead"):setup({
    branch_prefix = "on",
    branch_symbol = " ",
    branch_borders = "()",
  })
  ```

  </details>

- [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)

  ![preview-spaceship](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-spaceship.png)

  <details>
  <summary>Config</summary>

  ```lua
  require("githead"):setup({
    order = {
      "__spacer__",
      "branch",
      "remote",
      "__spacer__",
      "tag",
      "__spacer__",
      "commit",
      "__spacer__",
      "behind_ahead_remote",
      "stashes",
      "state",
      "staged",
      "unstaged",
      "untracked",
    },

    show_numbers = false,

    branch_symbol = " ",
    branch_prefix = "on",
  })
  ```

  </details>

- [robertgzr/porcelain](https://github.com/robertgzr/porcelain)

  ![preview-porcelain](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-porcelain.png)

  <details>
  <summary>Config</summary>

  ```lua
  require("githead"):setup({
    order = {
      "__spacer__",
      "branch",
      "commit",
      "__spacer__",
      "behind_ahead_remote",
      "__spacer__",
      "untracked",
      "state",
      "unstaged",
      "__spacer__",
      "staged",
    },

    show_numbers = false,

    show_branch = true,
    branch_prefix = "",
    branch_color = "#288BD2",

    always_show_commit = true,
    commit_color = "#859A00",

    show_behind_ahead_remote = true,
    behind_remote_symbol = "↓",
    ahead_remote_symbol = "↑",
    behind_remote_color = "#DC322E",
    ahead_remote_color = "#4DB6AC",

    show_state = true,
    show_state_prefix = false,
    state_symbol = "!!",
    state_color = "#B58901",

    staged_symbol = "✔",
    staged_color = "green",

    unstaged_symbol = "Δ",
    unstaged_color = "#288BD2",

    untracked_symbol = "?",
    untracked_color = "#415F65",
  })
  ```

  </details>

- Minimal (No color)

  ![preview-minimal-no-color](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-minimal-no-color.png)

  <details>
  <summary>Config</summary>

  ```lua
  require("githead"):setup({
    branch_color = "",

    remote_branch_prefix = "@",
    remote_branch_color = "",

    tag_color = "",

    commit_color = "",

    ahead_remote_symbol = "+",
    ahead_remote_color = "",
    behind_remote_symbol = "-",
    behind_remote_color = "",

    stashes_symbol = "*",
    stashes_color = "",

    show_state_prefix = false,
    state_symbol = "~",
    state_color = "",

    staged_symbol = "S",
    staged_color = "",

    unstaged_symbol = "U",
    unstaged_color = "",

    untracked_symbol = "N",
    untracked_color = "",
  })
  ```

  </details>

- Vibrant (Full)

  ![preview-vibrant-full](https://github.com/llanosrocas/githead.yazi/blob/main/.github/images/preview-vibrant-full.png)

  <details>
  <summary>Config</summary>

  ```lua
  require("githead"):setup({
    order = {
      "__spacer__",
      "stashes",
      "__spacer__",
      "state",
      "__spacer__",
      "staged",
      "__spacer__",
      "unstaged",
      "__spacer__",
      "untracked",
      "__spacer__",
      "branch",
      "remote_branch",
      "__spacer__",
      "tag",
      "__spacer__",
      "commit",
      "__spacer__",
      "behind_ahead_remote",
      "__spacer__",
    },

    branch_borders = "{}",
    branch_prefix = "|",
    branch_color = "#7aa2f7",
    remote_branch_color = "#9ece6a",
    always_show_remote_branch = true,
    always_show_remote_repo = true,

    tag_symbol = "󰓼",
    always_show_tag = true,
    tag_color = "#bb9af7",

    commit_symbol = "",
    always_show_commit = true,
    commit_color = "#e0af68",

    staged_color = "#73daca",
    staged_symbol = "●",

    unstaged_color = "#e0af68",
    unstaged_symbol = "✗",

    untracked_color = "#f7768e",
    untracked_symbol = "?",

    state_color = "#f5c359",
    state_symbol = "󱐋",

    stashes_color = "#565f89",
    stashes_symbol = "⚑",
  })
  ```

  </details>

## Features

- [x] Current branch
- [x] Remote and remote branch
- [x] Latest tag
- [x] Latest commit
- [x] Behind/Ahead of the remote
- [x] Stashes
- [x] States
  - [x] merge
  - [x] cherry
  - [x] rebase (+ done counter)
  - [x] revert
  - [x] bisect
- [x] Staged
- [x] Unstaged
- [x] Untracked

### Under the hood

The goal is to use minimum amount of shell commands.

- Branch, stashes, staged files, unstaged files, untracked files.

```shell
git status --ignore-submodules=dirty --branch --show-stash --ahead-behind
```

- Remote branch and repo:

```shell
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}
```

- Latest tag and commit:

```shell
git log --format="commit %h%d" -n 1
```

## Credits

- [yazi source code](https://github.com/sxyazi/yazi)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [twio142](https://github.com/twio142/githead.yazi)
