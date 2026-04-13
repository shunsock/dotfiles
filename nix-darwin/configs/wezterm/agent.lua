local wezterm = require("wezterm")

local M = {}

-- Process tree cache (3-second TTL to avoid running ps on every tick)
local ps_cache = nil
local ps_cache_time = 0
local CACHE_TTL = 3

-- Per-pane claude state: pane_id -> "Running" | "Idle"
local pane_states = {}

-- Per-tab unseen completion tracking: tab_id -> true if idle & not yet viewed
local unseen_idle = {}

-- Previous tab states for detecting Running -> Idle transitions: tab_id -> "Running" | "Idle" | nil
local prev_tab_states = {}

-- Tab indicator colors (Tokyo Night Storm palette)
local STYLE = {
  Running = {
    active = { dot = "#7aa2f7", bg = "#1a1b36", text = "#c0caf5" },
    inactive = { dot = "#3d59a1", bg = "#16161e", text = "#565f89" },
  },
  Idle = {
    active = { dot = "#9ece6a", bg = "#1a2b1a", text = "#c0caf5" },
    inactive = { dot = "#4e6b3c", bg = "#16161e", text = "#565f89" },
  },
}

--- Parse `ps -eo pid,ppid,comm` output into a list of process records.
--- @param output string
--- @return table[]
local function parse_ps_output(output)
  local processes = {}
  local first_line = true
  for line in output:gmatch("[^\r\n]+") do
    if first_line then
      first_line = false
    else
      local pid_str, ppid_str, comm = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
      if pid_str then
        local name = comm:match("([^/]+)$") or comm
        name = name:match("^%s*(.-)%s*$")
        table.insert(processes, {
          pid = tonumber(pid_str),
          ppid = tonumber(ppid_str),
          name = name,
        })
      end
    end
  end
  return processes
end

--- Build parent/child lookup tables from a flat process list.
--- @param processes table[]
--- @return table
local function build_process_tree(processes)
  local by_pid = {}
  local children = {}
  for _, proc in ipairs(processes) do
    by_pid[proc.pid] = proc
    if not children[proc.ppid] then
      children[proc.ppid] = {}
    end
    table.insert(children[proc.ppid], proc.pid)
  end
  return { by_pid = by_pid, children = children }
end

--- Return a cached process tree, refreshing if TTL expired.
--- @return table|nil
local function get_process_tree()
  local now = os.time()
  if ps_cache and (now - ps_cache_time) < CACHE_TTL then
    return ps_cache
  end

  local success, stdout, _ = wezterm.run_child_process({ "ps", "-eo", "pid,ppid,comm" })
  if not success then
    return nil
  end

  ps_cache = build_process_tree(parse_ps_output(stdout))
  ps_cache_time = now
  return ps_cache
end

--- Walk up the process tree to find a "claude" ancestor.
--- @param pid number
--- @param tree table
--- @return number|nil -- claude PID if found
local function find_claude_ancestor(pid, tree)
  local visited = {}
  local current = pid
  while current and current > 1 and not visited[current] do
    visited[current] = true
    local proc = tree.by_pid[current]
    if not proc then
      break
    end
    if proc.name == "claude" then
      return current
    end
    current = proc.ppid
  end
  return nil
end

--- Check whether a process has a "caffeinate" child (Running indicator).
--- @param pid number
--- @param tree table
--- @return boolean
local function has_caffeinate_child(pid, tree)
  for _, child_pid in ipairs(tree.children[pid] or {}) do
    local child = tree.by_pid[child_pid]
    if child and child.name == "caffeinate" then
      return true
    end
  end
  return false
end

--- Scan all mux panes and update pane_states table.
local function refresh_pane_states()
  local tree = get_process_tree()
  if not tree then
    return
  end

  local new_states = {}
  for _, mux_win in ipairs(wezterm.mux.all_windows()) do
    for _, tab in ipairs(mux_win:tabs()) do
      for _, pane in ipairs(tab:panes()) do
        local info = pane:get_foreground_process_info()
        if info then
          local claude_pid = find_claude_ancestor(info.pid, tree)
          if claude_pid then
            local running = has_caffeinate_child(claude_pid, tree)
            new_states[pane:pane_id()] = running and "Running" or "Idle"
          end
        end
      end
    end
  end
  pane_states = new_states
end

--- Determine the aggregate claude state for a tab's panes.
--- Running takes priority over Idle.
--- @param panes table[] -- TabInformation.panes (PaneInformation list)
--- @return string|nil -- "Running", "Idle", or nil
local function resolve_tab_state(panes)
  local has_idle = false
  for _, pane_info in ipairs(panes) do
    local state = pane_states[pane_info.pane_id]
    if state == "Running" then
      return "Running"
    elseif state == "Idle" then
      has_idle = true
    end
  end
  return has_idle and "Idle" or nil
end

--- Register event handlers for agent monitoring.
function M.setup()
  wezterm.on("update-right-status", function(_window, _pane)
    refresh_pane_states()

    -- Detect Running -> Idle transitions on inactive tabs to mark as unseen
    for _, mux_win in ipairs(wezterm.mux.all_windows()) do
      local active_tab = mux_win:active_tab()
      local active_tab_id = active_tab and active_tab:tab_id()
      for _, tab in ipairs(mux_win:tabs()) do
        local tab_id = tab:tab_id()
        local current_state = resolve_tab_state(tab:panes())
        local prev_state = prev_tab_states[tab_id]

        if current_state == "Idle" and prev_state == "Running" and tab_id ~= active_tab_id then
          unseen_idle[tab_id] = true
        end

        -- Clear unseen flag when user views the tab
        if tab_id == active_tab_id then
          unseen_idle[tab_id] = nil
        end

        -- Clear unseen flag if claude is no longer present
        if not current_state then
          unseen_idle[tab_id] = nil
        end

        prev_tab_states[tab_id] = current_state
      end
    end
  end)

  wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, max_width)
    local title = tab.active_pane.title
    local state = resolve_tab_state(tab.panes)
    local tab_id = tab.tab_id
    local is_active = tab.is_active

    -- Clear unseen flag when user views the tab
    if is_active then
      unseen_idle[tab_id] = nil
    end

    if not state then
      return title
    end

    if state == "Running" then
      -- Reserve 2 chars for "● " prefix
      local available = max_width - 2
      if #title > available and available > 0 then
        title = title:sub(1, available)
      end

      local s = is_active and STYLE.Running.active or STYLE.Running.inactive
      return {
        { Background = { Color = s.bg } },
        { Foreground = { Color = s.dot } },
        { Text = "● " },
        { Foreground = { Color = s.text } },
        { Text = title },
      }
    end

    -- state == "Idle": green background, with ・ dot only if unseen
    local s = is_active and STYLE.Idle.active or STYLE.Idle.inactive
    if unseen_idle[tab_id] then
      -- Reserve 2 chars for "+ " prefix
      local available = max_width - 2
      if #title > available and available > 0 then
        title = title:sub(1, available)
      end

      return {
        { Background = { Color = s.bg } },
        { Foreground = { Color = s.dot } },
        { Text = "+ " },
        { Foreground = { Color = s.text } },
        { Text = title },
      }
    end

    return {
      { Background = { Color = s.bg } },
      { Foreground = { Color = s.text } },
      { Text = title },
    }
  end)
end

return M
