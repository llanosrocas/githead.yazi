---@diagnostic disable: undefined-global

local save = ya.sync(function(this, cwd, output)
  if cwd:match("%.git[/\\]") or cwd:match("%.git$") then
    this.output = nil
    return
  end
  if cx.active.current.cwd == Url(cwd) then
    this.output = output
    ui.render()
  end
end)

return {
  setup = function(this, options)
    options = options or {}

    local config = {
      order = options.order or {
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

      show_numbers = options.show_numbers == nil and true
        or options.show_numbers,

      show_branch = options.show_branch == nil and true or options.show_branch,
      branch_prefix = options.branch_prefix or "",
      branch_color = options.branch_color or "blue",
      branch_symbol = options.branch_symbol or "",
      branch_borders = options.branch_borders or "",

      show_remote_branch = options.show_remote_branch == nil and true
        or options.show_remote_branch,
      always_show_remote_branch = options.always_show_remote_branch == nil
          and false
        or options.always_show_remote_branch,
      always_show_remote_repo = options.always_show_remote_repo == nil
          and false
        or options.always_show_remote_repo,
      remote_branch_prefix = options.remote_branch_prefix or ":",
      remote_branch_color = options.remote_branch_color or "bright magenta",

      show_tag = options.show_tag == nil and true or options.show_tag,
      always_show_tag = options.always_show_tag == nil and false
        or options.always_show_tag,
      tag_color = options.tag_color or "magenta",
      tag_symbol = options.tag_symbol == nil and "#" or options.tag_symbol,

      show_commit = options.show_commit == nil and true or options.show_commit,
      always_show_commit = options.always_show_commit == nil and false
        or options.always_show_commit,
      commit_color = options.commit_color or "bright magenta",
      commit_symbol = options.commit_symbol == nil and "@"
        or options.commit_symbol,

      show_behind_ahead_remote = options.show_behind_ahead_remote == nil
          and true
        or options.show_behind_ahead_remote,
      behind_remote_color = options.behind_remote_color or "bright magenta",
      behind_remote_symbol = options.behind_remote_symbol or "⇣",
      ahead_remote_color = options.ahead_remote_color or "bright magenta",
      ahead_remote_symbol = options.ahead_remote_symbol or "⇡",

      show_stashes = options.show_stashes == nil and true
        or options.show_stashes,
      stashes_color = options.stashes_color or "bright magenta",
      stashes_symbol = options.stashes_symbol or "$",

      show_state = options.show_state == nil and true or options.show_state,
      show_state_prefix = options.show_state_prefix == nil and true
        or options.show_state_prefix,
      state_color = options.state_color or "red",
      state_symbol = options.state_symbol or "~",

      show_staged = options.show_staged == nil and true or options.show_staged,
      staged_color = options.staged_color or "bright yellow",
      staged_symbol = options.staged_symbol or "+",

      show_unstaged = options.show_unstaged == nil and true
        or options.show_unstaged,
      unstaged_color = options.unstaged_color or "bright yellow",
      unstaged_symbol = options.unstaged_symbol or "!",

      show_untracked = options.show_untracked == nil and true
        or options.show_untracked,
      untracked_color = options.untracked_color or "bright blue",
      untracked_symbol = options.untracked_symbol or "?",
    }

    --- @param data GitStatusData
    function Header:render_branch(data)
      local branch = data.branch

      if not branch then
        return nil
      end

      local left_border = config.branch_borders:sub(1, 1)
      local right_border = config.branch_borders:sub(2, 2)

      local branch_string = ""

      if config.branch_symbol == "" then
        branch_string = left_border .. branch .. right_border
      else
        branch_string = left_border
          .. config.branch_symbol
          .. branch
          .. right_border
      end

      local branch_prefix = config.branch_prefix == "" and ""
        or config.branch_prefix .. " "

      return ui.Line({
        ui.Span(branch_prefix),
        ui.Span(branch_string):fg(config.branch_color),
      })
    end

    --- @param data GitStatusData
    function Header:render_remote_branch(data)
      local branch = data.branch
      local remote_branch = data.remote_branch
      local remote_repo = data.remote_repo

      if not remote_branch then
        return nil
      end

      local show_remote = config.always_show_remote_branch
        or branch ~= remote_branch
      if not show_remote then
        return nil
      end

      local remote_branch_label = config.always_show_remote_repo
          and (remote_repo .. "/" .. remote_branch)
        or remote_branch

      return ui.Line({
        ui.Span(config.remote_branch_prefix),
        ui.Span(remote_branch_label):fg(config.remote_branch_color),
      })
    end

    --- @param data GitStatusData
    function Header:render_tag(data)
      local branch = data.branch
      local tag = data.tag

      if not tag then
        return nil
      end

      if not branch or config.always_show_tag then
        return ui.Line({
          ui.Span(config.tag_symbol),
          ui.Span(tag):fg(config.tag_color),
        })
      end
    end

    --- @param data GitStatusData
    function Header:render_commit(data)
      local branch = data.branch
      local tag = data.tag
      local commit = data.commit

      if not commit then
        return nil
      end

      if (not branch and not tag) or config.always_show_commit then
        return ui.Line({
          ui.Span(config.commit_symbol),
          ui.Span(commit):fg(config.commit_color),
        })
      end
    end

    --- @param data GitStatusData
    function Header:render_behind_ahead_remote(data)
      local behind = data.behind_remote
      local ahead = data.ahead_remote

      local behind_label = behind
        and behind > 0
        and ui.Span(
          config.behind_remote_symbol .. (config.show_numbers and behind or "")
        ):fg(config.behind_remote_color)

      local ahead_label = ahead
        and ahead > 0
        and ui.Span(
          config.ahead_remote_symbol .. (config.show_numbers and ahead or "")
        ):fg(config.ahead_remote_color)

      if ahead_label and behind_label then
        return ui.Line({
          behind_label,
          ahead_label,
        })
      elseif ahead_label then
        return ahead_label
      elseif behind_label then
        return behind_label
      else
        return nil
      end
    end

    --- @param data GitStatusData
    function Header:render_stashes(data)
      local stashes_count = data.stashes

      if not stashes_count then
        return nil
      end

      local stashes_label = config.stashes_symbol

      if config.show_numbers then
        stashes_label = stashes_label .. stashes_count
      end

      return ui.Span(stashes_label):fg(config.stashes_color)
    end

    --- @param data GitStatusData
    function Header:render_state(data)
      local state_prefix = data.state_prefix
      local unmerged_count = data.unmerged_count
      local rebase_done = data.rebase_done
      local rebase_total = data.rebase_total

      if state_prefix then
        local state_label = ""
        if config.show_state_prefix then
          state_label = state_prefix
          if
            state_prefix == "rebase-i"
            and config.show_numbers
            and rebase_done
            and rebase_total
          then
            state_label = state_label
              .. " "
              .. rebase_done
              .. "/"
              .. rebase_total
          end
        end

        local unmerged_label = ""
        local symbol = ""

        if unmerged_count and unmerged_count > 0 then
          symbol = " " .. config.state_symbol
          if config.show_numbers then
            unmerged_label = tostring(unmerged_count)
          end
        end

        return ui.Span(state_label .. symbol .. unmerged_label)
          :fg(config.state_color)
      end
      return nil
    end

    --- @param data GitStatusData
    function Header:render_staged(data)
      local staged = data.staged

      if staged then
        local staged_label = config.staged_symbol

        if config.show_numbers then
          local filtered_staged = staged:gsub("^[%s]*%b()[%s]*", "")

          local staged_count = 0
          for line in filtered_staged:gmatch("[^\r\n]+") do
            if line:match("%S") then
              staged_count = staged_count + 1
            end
          end

          staged_label = staged_label .. staged_count
        end

        return ui.Span(staged_label):fg(config.staged_color)
      end

      return nil
    end

    --- @param data GitStatusData
    function Header:render_unstaged(data)
      local unstaged = data.unstaged

      if unstaged then
        local unstaged_label = config.unstaged_symbol

        if config.show_numbers then
          local filtered_unstaged =
            unstaged:gsub("^[%s]*%b()[\r\n]*", ""):gsub("^[%s]*%b()[\r\n]*", "")

          local unstaged_count = 0
          for line in filtered_unstaged:gmatch("[^\r\n]+") do
            if line:match("%S") then
              unstaged_count = unstaged_count + 1
            end
          end

          unstaged_label = unstaged_label .. unstaged_count
        end

        return ui.Span(unstaged_label):fg(config.unstaged_color)
      end

      return nil
    end

    --- @param data GitStatusData
    function Header:render_untracked(data)
      local untracked = data.untracked

      if untracked then
        local untracked_label = config.untracked_symbol

        if config.show_numbers then
          local filtered_untracked = untracked:gsub("^[%s]*%b()[\r\n]*", "")
          local untracked_count = 0

          for line in filtered_untracked:gmatch("[^\r\n]+") do
            if line:match("%S") then
              untracked_count = untracked_count + 1
            end
          end

          untracked_label = untracked_label .. untracked_count
        end

        return ui.Span(untracked_label):fg(config.untracked_color)
      end

      return nil
    end

    function Header:githead()
      --- @type GitStatusData
      local data = this.output

      if not data then
        return ui.Line({})
      end

      local head = {}

      for _, key in ipairs(config.order) do
        if key == "__spacer__" then
          if head[#head] ~= " " then
            table.insert(head, " ")
          end
        else
          local fn = self["render_" .. key]
          local is_shown = config["show_" .. key]

          if fn and is_shown then
            local value = fn(self, data)
            if value then
              table.insert(head, value)
            end
          end
        end
      end

      return ui.Line(head)
    end

    Header:children_add(Header.githead, 2000, Header.LEFT)

    local callback = function()
      local cwd = cx.active.current.cwd
      ya.emit("plugin", {
        this._id,
        ya.quote(tostring(cwd), true),
      })
    end

    ps.sub("cd", callback)
    ps.sub("rename", callback)
    ps.sub("bulk", callback)
    ps.sub("move", callback)
    ps.sub("trash", callback)
    ps.sub("delete", callback)
    ps.sub("tab", callback)
  end,

  entry = function(_, job)
    local args = job.args or job

    ---@class GitStatusData
    ---@field ahead_remote? integer
    ---@field behind_remote? integer
    ---@field branch? string
    ---@field commit? string
    ---@field rebase_done? integer
    ---@field remote_branch? string
    ---@field remote_repo? string
    ---@field staged? string
    ---@field stashes? integer
    ---@field state_prefix? "bisect"|"cherry"|"merge"|"rebase-i"|"revert"
    ---@field tag? string
    ---@field unmerged_count? integer
    ---@field unstaged? string
    ---@field untracked? string
    local data = {}

    --- @param status string
    local get_behind_ahead_remote = function(status)
      local diverged_ahead, diverged_behind =
        status:match("have (%d+) and (%d+) different")
      if diverged_ahead and diverged_behind then
        data.behind_remote = tonumber(diverged_behind)
        data.ahead_remote = tonumber(diverged_ahead)
      else
        local behind_remote = status:match("behind %S+ by (%d+) commits?")
        local ahead_remote = status:match("ahead of %S+ by (%d+) commits?")

        data.behind_remote = tonumber(behind_remote)
        data.ahead_remote = tonumber(ahead_remote)
      end
    end

    --- @param status string
    local get_branch = function(status)
      data.branch = status:match("On branch (%S+)")
    end

    --- @param status string
    local get_stashes = function(status)
      data.stashes = tonumber(status:match("Your stash currently has (%d+)"))
    end

    --- @param status string
    local get_state = function(status)
      local unmerged = status:match("Unmerged paths:%s*(.-)%s*\n\n")
      if unmerged then
        local filtered_unmerged =
          unmerged:gsub("^[%s]*%b()[%s]*", ""):gsub("^[%s]*%b()[%s]*", "")
        local count = 0
        for line in filtered_unmerged:gmatch("[^\r\n]+") do
          if line:match("%S") then
            count = count + 1
          end
        end
        data.unmerged_count = count
      end

      if status:find("git merge") then
        data.state_prefix = "merge"
      elseif status:find("git cherry%-pick") then
        data.state_prefix = "cherry"
      elseif status:find("git rebase") then
        data.state_prefix = "rebase-i"
        local commands_done = status:match("%((%d+) commands? done%)")
        if commands_done then
          data.rebase_done = commands_done
          if not data.unmerged_count then
            data.rebase_total = commands_done
          else
            data.rebase_total = data.unmerged_count
          end
        end
      elseif status:find("git revert") then
        data.state_prefix = "revert"
      elseif status:find("git bisect") then
        data.state_prefix = "bisect"
      end
    end

    --- @param status string
    local get_staged = function(status)
      data.staged = status:match("Changes to be committed:%s*(.-)%s*\n\n")
    end

    --- @param status string
    local get_unstaged = function(status)
      data.unstaged =
        status:match("Changes not staged for commit:%s*(.-)%s*\n\n")
    end

    --- @param status string
    local get_untracked = function(status)
      data.untracked = status:match("Untracked files:%s*(.-)%s*\n\n")
    end

    local get_status = function()
      local cmd = Command("git")
        :arg({
          "status",
          "--ignore-submodules=dirty",
          "--branch",
          "--show-stash",
          "--ahead-behind",
        })
        :cwd(args[1])
        :env("LANGUAGE", "en_US.UTF-8")
        :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        local status = cmd_output.stdout

        get_branch(status)
        get_behind_ahead_remote(status)
        get_stashes(status)
        get_state(status)
        get_staged(status)
        get_unstaged(status)
        get_untracked(status)
      end
    end

    local get_remote_branch = function()
      local cmd = Command("git")
        :arg({
          "rev-parse",
          "--abbrev-ref",
          "--symbolic-full-name",
          "@{upstream}",
        })
        :cwd(args[1])
        :env("LANGUAGE", "en_US.UTF-8")
        :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        local remote_branch = cmd_output.stdout

        data.remote_branch =
          remote_branch:gsub("[\r\n]", ""):match("^[^/]+/(.+)")
        data.remote_repo = remote_branch:gsub("[\r\n]", ""):match("^([^/]+)/")
      end
    end

    --- @param log string
    local get_tag = function(log)
      data.tag = log:match("tag: ([^, )]+)")
    end

    --- @param log string
    local get_commit = function(log)
      data.commit = log:match("^commit%s+([a-f0-9]+)")
    end

    local get_git_log = function()
      local cmd = Command("git")
        :arg({ "log", "--format=commit %h%d", "-n", "1" })
        :cwd(args[1])
        :env("LANGUAGE", "en_US.UTF-8")
        :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        local log = cmd_output.stdout

        get_tag(log)
        get_commit(log)
      end
    end

    get_status()
    get_remote_branch()
    get_git_log()

    save(args[1], data)
  end,
}
