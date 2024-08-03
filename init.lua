local get_status = ya.sync(function()
  local command =
  "LANGUAGE=en_US.UTF-8 git status --ignore-submodules=dirty --branch --show-stash --ahead-behind 2>/dev/null"

  local handle = io.popen(command)
  local status = handle:read("*a")
  handle:close()

  return status
end)

local function setup(_, options)
  options = options or {}

  local config = {
    show_branch = options.show_branch == nil and true or options.show_branch,
    branch_prefix = options.branch_prefix or "on",
    branch_color = options.branch_color or "blue",
    branch_symbol = options.branch_symbol or "",
    branch_borders = options.branch_borders or "()",

    commit_color = options.commit_color or "bright magenta",
    commit_symbol = options.commit_symbol or "@",

    show_behind_ahead = options.behind_ahead == nil and true or options.behind_ahead,
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

  function Header:get_branch(status)
    local branch = status:match("On branch (%S+)")

    if branch == nil then
      local commit = status:match("onto (%S+)") or status:match("detached at (%S+)")

      if commit == nil then
        return ""
      else
        local branch_prefix = config.branch_prefix == "" and " " or " " .. config.branch_prefix .. " "
        local commit_prefix = config.commit_symbol == "" and "" or config.commit_symbol

        return ui.Line {
          ui.Span(branch_prefix .. commit_prefix),
          ui.Span(commit):fg(config.commit_color)
        }
      end
    else
      local left_border = config.branch_borders:sub(1, 1)
      local right_border = config.branch_borders:sub(2, 2)

      local branch_string = ""

      if config.branch_symbol == "" then
        branch_string = left_border .. branch .. right_border
      else
        branch_string = left_border .. config.branch_symbol .. " " .. branch .. right_border
      end

      local branch_prefix = config.branch_prefix == "" and " " or " " .. config.branch_prefix .. " "

      return ui.Line {
        ui.Span(branch_prefix),
        ui.Span(branch_string):fg(config.branch_color)
      }
    end
  end

  function Header:get_behind_ahead(status)
    local diverged_ahead, diverged_behind = status:match("have (%d+) and (%d+) different")

    if diverged_ahead and diverged_behind then
      return ui.Line {
        ui.Span(" " .. config.behind_symbol .. diverged_behind):fg(config.behind_color),
        ui.Span(config.ahead_symbol .. diverged_ahead):fg(config.ahead_color)
      }
    else
      local behind = status:match("behind %S+ by (%d+) commit")
      local ahead = status:match("ahead of %S+ by (%d+) commit")

      if ahead then
        return ui.Span(" " .. config.ahead_symbol .. ahead):fg(config.ahead_color)
      elseif behind then
        return ui.Span(" " .. config.behind_symbol .. behind):fg(config.behind_color)
      else
        return ""
      end
    end
  end

  function Header:get_stashes(status)
    local stashes = tonumber(status:match("Your stash currently has (%S+)"))

    return stashes ~= nil and ui.Span(" " .. config.stashes_symbol .. stashes):fg(config.stashes_color) or ""
  end

  function Header:get_state(status)
    local result = status:match("Unmerged paths:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[%s]*", ""):gsub("^[%s]*%b()[%s]*", "")

      local unmerged = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          unmerged = unmerged + 1
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
            state_name = state_name .. done .. "/" .. unmerged .. " "
          end
        else
          state_name = ""
        end
      end

      return ui.Span(" " .. state_name .. config.state_symbol .. unmerged):fg(config.state_color)
    else
      return ""
    end
  end

  function Header:get_staged(status)
    local result = status:match("Changes to be committed:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[%s]*", "")

      local staged = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          staged = staged + 1
        end
      end

      return ui.Span(" " .. config.staged_symbol .. staged):fg(config.staged_color)
    else
      return ""
    end
  end

  function Header:get_unstaged(status)
    local result = status:match("Changes not staged for commit:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[\r\n]*", ""):gsub("^[%s]*%b()[\r\n]*", "")

      local unstaged = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          unstaged = unstaged + 1
        end
      end

      return ui.Span(" " .. config.unstaged_symbol .. unstaged):fg(config.unstaged_color)
    else
      return ""
    end
  end

  function Header:get_untracked(status)
    local result = status:match("Untracked files:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[\r\n]*", "")

      local untracked = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          untracked = untracked + 1
        end
      end

      return ui.Span(" " .. config.untracked_symbol .. untracked):fg(config.untracked_color)
    else
      return ""
    end
  end

  function Header:githead()
    local status = get_status()

    local branch = config.show_branch and self:get_branch(status) or ""
    local behind_ahead = config.show_behind_ahead and self:get_behind_ahead(status) or ""
    local stashes = config.show_stashes and self:get_stashes(status) or ""
    local state = config.show_state and self:get_state(status) or ""
    local staged = config.show_staged and self:get_staged(status) or ""
    local unstaged = config.show_unstaged and self:get_unstaged(status) or ""
    local untracked = config.show_untracked and self:get_untracked(status) or ""

    return ui.Line {
      branch,
      behind_ahead,
      stashes,
      state,
      staged,
      unstaged,
      untracked,
    }
  end

  Header:children_add(Header.githead, 2000, Header.LEFT)
end

return { setup = setup }
