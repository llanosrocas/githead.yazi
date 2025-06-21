---@diagnostic disable: undefined-global

local save = ya.sync(function(this, cwd, output)
  if cx.active.current.cwd == Url(cwd) then
    this.output = output
    ya.render()
  end
end)

return {
  setup = function(this, options)
    options = options or {}

    local config = {
      order = options.order or {
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
      show_numbers = options.show_numbers == nil and true or options.show_numbers,

      show_branch = options.show_branch == nil and true or options.show_branch,
      branch_prefix = options.branch_prefix or "",
      branch_color = options.branch_color or "blue",
      branch_symbol = options.branch_symbol or "",
      branch_borders = options.branch_borders or "",

      show_remote = options.show_remote == nil and true or options.show_remote,
      always_show_remote = options.always_show_remote == nil and true or options.always_show_remote,
      remote_prefix = options.remote_prefix or ":",
      remote_color = options.remote_color or "bright magenta",

      show_tag = options.show_tag == nil and true or options.show_tag,
      always_show_tag = options.always_show_tag == nil and true or options.always_show_tag,
      tag_color = options.tag_color or "bright magenta",
      tag_symbol = options.tag_symbol == nil and "#" or options.tag_symbol,

      show_commit = options.show_commit == nil and true or options.show_commit,
      always_show_commit = options.always_show_commit == nil and true or options.always_show_commit,
      commit_color = options.commit_color or "bright magenta",
      commit_symbol = options.commit_symbol == nil and "@" or options.commit_symbol,

      show_behind_ahead_remote = options.show_behind_ahead_remote == nil and true or options.show_behind_ahead_remote,
      behind_color = options.behind_color or "bright magenta",
      behind_symbol = options.behind_symbol or "⇣",
      ahead_color = options.ahead_color or "bright magenta",
      ahead_symbol = options.ahead_symbol or "⇡",

      show_stashes = options.show_stashes == nil and true or options.show_stashes,
      stashes_color = options.stashes_color or "bright magenta",
      stashes_symbol = options.stashes_symbol or "$",

      show_state = options.show_state == nil and true or options.show_state,
      show_state_prefix = options.show_state_prefix == nil and true or options.show_state_prefix,
      state_color = options.state_color or "red",
      state_symbol = options.state_symbol or "~",

      show_staged = options.show_staged == nil and true or options.show_staged,
      staged_color = options.staged_color or "bright yellow",
      staged_symbol = options.staged_symbol or "+",

      show_unstaged = options.show_unstaged == nil and true or options.show_unstaged,
      unstaged_color = options.unstaged_color or "bright yellow",
      unstaged_symbol = options.unstaged_symbol or "!",

      show_untracked = options.show_untracked == nil and true or options.show_untracked,
      untracked_color = options.untracked_color or "bright blue",
      untracked_symbol = options.untracked_symbol or "?",
    }


    function Header:render_branch(data)
      local branch = data.branch

      if not branch then return nil end

      local left_border = config.branch_borders:sub(1, 1)
      local right_border = config.branch_borders:sub(2, 2)

      local branch_string = ""

      if config.branch_symbol == "" then
        branch_string = left_border .. branch .. right_border
      else
        branch_string = left_border .. config.branch_symbol .. branch .. right_border
      end

      local branch_prefix = config.branch_prefix == "" and "" or config.branch_prefix .. " "

      return ui.Line({
        ui.Span(branch_prefix),
        ui.Span(branch_string):fg(config.branch_color),
      })
    end

    function Header:render_remote(data)
      local branch = data.branch
      local remote = data.remote or branch

      if branch and remote then
        if config.always_show_remote or branch ~= remote then
          return ui.Line({
            ui.Span(config.remote_prefix),
            ui.Span(remote):fg(config.remote_color),
          })
        end
      end

      return nil
    end

    function Header:render_tag(data)
      local branch = data.branch
      local tag = data.tag

      if not tag then return nil end

      if not branch or config.always_show_tag then
        return ui.Line({
          ui.Span(config.tag_symbol),
          ui.Span(tag):fg(config.tag_color),
        })
      end
    end

    function Header:render_commit(data)
      local branch = data.branch
      local tag = data.tag
      local commit = data.commit

      if not commit then return nil end

      if (not branch and not tag) or config.always_show_commit then
        return ui.Line({
          ui.Span(config.commit_symbol),
          ui.Span(commit):fg(config.commit_color),
        })
      end
    end

    function Header:render_behind_ahead_remote(data)
      local behind = data.behind_remote
      local ahead = data.ahead_remote

      local behind_label = behind and behind > 0
          and ui.Span(config.behind_symbol .. (config.show_numbers and behind or "")):fg(config
            .behind_color)

      local ahead_label = ahead and ahead > 0
          and ui.Span(config.ahead_symbol .. (config.show_numbers and ahead or "")):fg(config.ahead_color)

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

    function Header:render_stashes(data)
      local status = data.status
      local stashes_count = tonumber(status:match("Your stash currently has (%d+)")) or 0

      if stashes_count == 0 then return nil end

      local stashes_label = config.stashes_symbol

      if config.show_numbers then stashes_label = stashes_label .. stashes_count end

      return ui.Span(stashes_label):fg(config.stashes_color)
    end

    function Header:render_state(data)
      local status = data.status
      local unmerged = status:match("Unmerged paths:%s*(.-)%s*\n\n")

      if unmerged then
        local filtered_unmerged = unmerged:gsub("^[%s]*%b()[%s]*", ""):gsub("^[%s]*%b()[%s]*", "")

        local unmerged_count = 0
        for line in filtered_unmerged:gmatch("[^\r\n]+") do
          if line:match("%S") then
            unmerged_count = unmerged_count + 1
          end
        end

        local state_name = ""

        if config.show_state_prefix then
          if status:find("git merge") then
            state_name = "merge "
          elseif status:find("git cherry%-pick") then
            state_name = "cherry "
          elseif status:find("git rebase") then
            state_name = "rebase "

            if status:find("done") then
              local done = status:match("%((%d+) com.- done%)") or ""
              state_name = state_name .. done .. "/" .. unmerged_count .. " "
            end
          elseif status:find("git revert") then
            state_name = "revert "
          end
        end

        return ui.Span(state_name .. config.state_symbol .. unmerged_count):fg(config.state_color)
      else
        if status:find("git bisect") then
          return ui.Span("bisect"):fg(config.state_color)
        end

        return nil
      end
    end

    function Header:render_staged(data)
      local status = data.status
      local staged = status:match("Changes to be committed:%s*(.-)%s*\n\n")

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

    function Header:render_unstaged(data)
      local status = data.status
      local unstaged = status:match("Changes not staged for commit:%s*(.-)%s*\n\n")

      if unstaged then
        local unstaged_label = config.unstaged_symbol

        if config.show_numbers then
          local filtered_unstaged = unstaged
              :gsub("^[%s]*%b()[\r\n]*", "")
              :gsub("^[%s]*%b()[\r\n]*", "")

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

    function Header:render_untracked(data)
      local status = data.status
      local untracked = status:match("Untracked files:%s*(.-)%s*\n\n")

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
        elseif self["render_" .. key] then
          local fn = self["render_" .. key]
          local is_shown = config["show_" .. key]

          if fn and is_shown then
            local value = fn(self, data)
            if value then
              table.insert(head, value)
            end
          end
        else
          table.insert(head, key)
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

    --- @param str string
    local function truncate(str)
      return str:gsub("[\r\n]", "")
    end

    local results = {}

    --- @param status string
    local get_behind_ahead_remote = function(status)
      local diverged_ahead, diverged_behind = status:match("have (%d+) and (%d+) different")
      if diverged_ahead and diverged_behind then
        results.behind_remote = tonumber(diverged_behind)
        results.ahead_remote = tonumber(diverged_ahead)
      else
        local behind_remote = status:match("behind %S+ by (%d+) commits?")
        local ahead_remote = status:match("ahead of %S+ by (%d+) commits?")


        results.behind_remote = tonumber(behind_remote)
        results.ahead_remote = tonumber(ahead_remote)
      end
    end

    local get_status = function()
      local cmd = Command("git")
          :arg({ "status", "--ignore-submodules=dirty", "--branch", "--show-stash", "--ahead-behind" })
          :cwd(args[1])
          :env("LANGUAGE", "en_US.UTF-8")
          :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        results.status = cmd_output.stdout

        local branch = cmd_output.stdout:match("On branch (%S+)")
        results.branch = branch

        get_behind_ahead_remote(cmd_output.stdout)
      end
    end

    local get_remote = function()
      local remote = Command("git")
          :arg({ "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
          :cwd(args[1])
          :env("LANGUAGE", "en_US.UTF-8")
          :stdout(Command.PIPED)
      local remote_output = remote:output()

      if remote_output then
        local remote_regex = "[^/]+/([^']+)";
        results.remote = truncate(remote_output.stdout):match(remote_regex)
      end
    end

    local get_tag = function()
      local cmd = Command("git")
          :arg({ "describe", "--tags", "--abbrev=0" })
          :cwd(args[1])
          :env("LANGUAGE", "en_US.UTF-8")
          :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        local tag = truncate(cmd_output.stdout)
        if #tag > 0 then
          results.tag = tag
        end
      end
    end

    local get_commit = function()
      local cmd = Command("git")
          :arg({ "rev-parse", "--short", "HEAD" })
          :cwd(args[1])
          :env("LANGUAGE", "en_US.UTF-8")
          :stdout(Command.PIPED)
      local cmd_output = cmd:output()

      if cmd_output then
        local commit = truncate(cmd_output.stdout)
        if #commit > 0 then
          results.commit = commit
        end
      end
    end

    get_status()
    get_remote()
    get_commit()
    get_tag()

    save(args[1], results)
  end,
}
