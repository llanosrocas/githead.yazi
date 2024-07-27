local function setup(_, options)
  options = options or {}

  local config = {
    show_branch = options.show_branch == nil and true or options.show_branch,
    branch_prefix = options.branch_prefix or "on",
    branch_symbol = options.branch_symbol or "",
    branch_borders = options.branch_borders or "()",

    commit_symbol = options.commit_symbol or "@",

    show_stashes = options.show_stashes == nil and true or options.show_stashes,
    stashes_symbol = options.stashes_symbol or "$",

    show_state = options.show_state == nil and true or options.show_state,
    show_state_prefix = options.show_state_prefix == nil and true or options.show_state_prefix,
    state_symbol = options.state_symbol or "~",

    show_staged = options.show_staged == nil and true or options.show_staged,
    staged_symbol = options.staged_symbol or "+",

    show_unstaged = options.show_unstaged == nil and true or options.show_unstaged,
    unstaged_symbol = options.unstaged_symbol or "!",

    show_untracked = options.show_untracked == nil and true or options.show_untracked,
    untracked_symbol = options.untracked_symbol or "?",
  }

  if options.theme then
    options = options.theme
  end

  local theme = {
    branch_color = options.branch_color or "blue",
    commit_color = options.commit_color or "bright magenta",
    stashes_color = options.stashes_color or "bright magenta",
    state_color = options.state_color or "red",
    staged_color = options.staged_color or "bright yellow",
    unstaged_color = options.unstaged_color or "bright yellow",
    untracked_color = options.untracked_color or "blue",
  }

  if Yatline == nil then
    Yatline = {}
    Yatline.coloreds = {}
    Yatline.coloreds.get = {}
  end

  local get_status = ya.sync(function()
    -- Instead of LANGUAGE, you can try LANG, LC_ALL. If the plugin does not show up.
    local handle = io.popen("LANGUAGE=en_US.UTF-8 git status --ignore-submodules=dirty --branch --show-stash --ahead-behind 2>/dev/null")
    local status = handle:read("*a")
    handle:close()

    return status
  end)

  function Yatline.coloreds.get:branch()
    local status = get_status()
    local branch = status:match("On branch (%S+)")

    if branch == nil then
      local commit = status:match("onto (%S+)") or status:match("detached at (%S+)")

      if commit == nil then
        return ""
      else
        local branch_prefix = config.branch_prefix == "" and "" or config.branch_prefix .. " "
        local commit_prefix = config.commit_symbol == "" and "" or config.commit_symbol

        return {{ " " .. branch_prefix .. commit_prefix .. commit .. " ", theme.commit_color }}
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

      local branch_prefix = config.branch_prefix == "" and "" or config.branch_prefix .. " "

      return {{ " " .. branch_prefix .. branch_string .. " ", theme.branch_color }}
    end
  end

  function Yatline.coloreds.get:stashes()
    local stashes = tonumber(get_status():match("Your stash currently has (%S+)"))

    return stashes ~= nil and {{ " " .. config.stashes_symbol .. stashes .. " ", theme.stashes_color }} or ""
  end

  function Yatline.coloreds.get:state()
    local status = get_status()
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

      return {{ " " .. state_name .. config.state_symbol .. unmerged .. " ", theme.state_color }}
    else
      return ""
    end
  end

  function Yatline.coloreds.get:staged()
    local result = get_status():match("Changes to be committed:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[%s]*", "")

      local staged = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          staged = staged + 1
        end
      end

      return {{ " " .. config.staged_symbol .. staged .. " ", theme.staged_color }}
    else
      return ""
    end
  end

  function Yatline.coloreds.get:unstaged()
    local result = get_status():match("Changes not staged for commit:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[\r\n]*", ""):gsub("^[%s]*%b()[\r\n]*", "")

      local unstaged = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          unstaged = unstaged + 1
        end
      end

      return {{ " " .. config.unstaged_symbol .. unstaged .. " ", theme.unstaged_color }}
    else
      return ""
    end
  end

  function Yatline.coloreds.get:untracked()
    local result = get_status():match("Untracked files:%s*(.-)%s*\n\n")
    if result then
      local filtered_result = result:gsub("^[%s]*%b()[\r\n]*", "")

      local untracked = 0
      for line in filtered_result:gmatch("[^\r\n]+") do
        if line:match("%S") then
          untracked = untracked + 1
        end
      end

      return {{ " " .. config.untracked_symbol .. untracked .. " ", theme.untracked_color }}
    else
      return ""
    end
  end

  function Yatline.coloreds.get:githead()
    local githead = {}

    local branch = config.show_branch and Yatline.coloreds.get:branch() or ""
    if branch ~= nil and branch ~= "" then
      table.insert(githead, branch[1])
    end

    local stashes = config.show_stashes and Yatline.coloreds.get:stashes() or ""
    if stashes ~= nil and stashes ~= "" then
      table.insert(githead, stashes[1])
    end

    local state = config.show_state and Yatline.coloreds.get:state() or ""
    if state ~= nil and state ~= "" then
      table.insert(githead, state[1])
    end

    local staged = config.show_staged and Yatline.coloreds.get:staged() or ""
    if staged ~= nil and staged ~= "" then
      table.insert(githead, staged[1])
    end

    local unstaged = config.show_unstaged and Yatline.coloreds.get:unstaged() or ""
    if unstaged ~= nil and unstaged ~= "" then
      table.insert(githead, unstaged[1])
    end

    local untracked = config.show_untracked and Yatline.coloreds.get:untracked() or ""
    if untracked ~= nil and untracked ~= "" then
      table.insert(githead, untracked[1])
    end

    if #githead == 0 then
      return ""
    else
      return githead
    end
  end

  function Header:githead()
    local githead = Yatline.coloreds.get:githead()

    local spans = {}
    if githead ~= "" then
      for _, value in ipairs(githead) do
        table.insert(spans, ui.Span(value[1]):fg(value[2]))
      end
    end

    return ui.Line(spans)
  end

  Header:children_add(Header.githead, 2000, Header.LEFT)
end

return { setup = setup }
