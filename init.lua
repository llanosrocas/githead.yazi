function setup(_, options)
  options = options or {}

  local config = {
    show_branch = options.show_branch == nil and true or options.show_branch,
    branch_color = options.branch_color or "blue",
    branch_symbol = options.branch_symbol or "",
    branch_borders = options.branch_borders or "()",

    show_stashes = options.show_stashes == nil and true or options.show_stashes,
    stashes_color = options.stashes_color or "bright magenta",
    stashes_symbol = options.stashes_symbol or "$",

    show_staged = options.show_staged == nil and true or options.show_staged,
    staged_color = options.staged_color or "bright yellow",
    staged_symbol = options.staged_symbol or "+",

    show_unstaged = options.show_unstaged == nil and true or options.show_unstaged,
    unstaged_color = options.unstaged_color or "bright yellow",
    unstaged_symbol = options.unstaged_symbol or "!",

    show_untracked = options.show_untracked == nil and true or options.show_untracked,
    untracked_color = options.untracked_color or "blue",
    untracked_symbol = options.untracked_symbol or "?",
  }

  function Header:get_status()
    local handle = io.popen("git status --ignore-submodules=dirty --branch --show-stash --ahead-behind 2>/dev/null")
    local status = handle:read("*a")
    handle:close()

    return status
  end

  function Header:get_branch(status)
    branch = status:match("On branch (%S+)")

    if branch == nil then
      return ""
    else
      local left_border = string.sub(config.branch_borders, 1, 1)
      local right_border = string.sub(config.branch_borders, 2, 2)

      local branch_string = ""

      if config.branch_symbol == "" then
        branch_string = left_border .. branch .. right_border
      else
        branch_string = left_border .. config.branch_symbol .. " " .. branch .. right_border
      end

      return ui.Line {
        ui.Span(" on "),
        ui.Span(branch_string):fg(config.branch_color)
      }
    end
  end

  function Header:get_stashes(status)
    local stashes = tonumber(status:match("Your stash currently has (%S+) entry"))

    return stashes ~= nil and ui.Span(" " .. config.stashes_symbol .. stashes):fg(config.stashes_color) or ""
  end

  function Header:get_staged(status)
    local result = string.match(status, "Changes to be committed:%s*(.-)%s*\n\n")
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
    local result = string.match(status, "Changes not staged for commit:%s*(.-)%s*\n\n")
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
    local result = string.match(status, "Untracked files:%s*(.-)%s*\n\n")
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
    local status = self:get_status()

    local branch = config.show_branch and self:get_branch(status) or ""
    local stashes = config.show_stashes and self:get_stashes(status) or ""
    local staged = config.show_staged and self:get_staged(status) or ""
    local unstaged = config.show_unstaged and self:get_unstaged(status) or ""
    local untracked = config.show_untracked and self:get_untracked(status) or ""

    return ui.Line {
      branch,
      stashes,
      staged,
      unstaged,
      untracked,
    }
  end

  Header._left = {
    { Header.cwd, id = 1, order = 1000 },
    { Header.githead, id = 2, order = 2000 },
  }
end

return { setup = setup }
