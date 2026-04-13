local wezterm = require("wezterm")

local M = {}

-- State tracking
local prev_states = {} -- claude_pid -> "Running" | "Idle"

-- Process tree cache
local ps_cache = nil
local ps_cache_time = 0
local CACHE_TTL = 3 -- seconds

--- Parse `ps -eo pid,ppid,comm` output into a list of process records.
--- @param output string
--- @return table[] -- each element: {pid=number, ppid=number, name=string}
local function parse_ps_output(output)
  local processes = {}
  local first_line = true
  for line in output:gmatch("[^\r\n]+") do
    if first_line then
      first_line = false -- skip header
    else
      local pid_str, ppid_str, comm = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
      if pid_str then
        local name = comm:match("([^/]+)$") or comm -- basename
        name = name:match("^%s*(.-)%s*$") -- trim whitespace
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

--- Build lookup tables from a flat process list.
--- @param processes table[]
--- @return table -- {by_pid: table<number, table>, children: table<number, number[]>}
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

--- Scan system processes and return a process tree (cached).
--- @return table|nil -- process tree or nil on failure
local function get_process_tree()
  local now = os.time()
  if ps_cache and (now - ps_cache_time) < CACHE_TTL then
    return ps_cache
  end

  local success, stdout, _ = wezterm.run_child_process({ "ps", "-eo", "pid,ppid,comm" })
  if not success then
    return nil
  end

  local processes = parse_ps_output(stdout)
  ps_cache = build_process_tree(processes)
  ps_cache_time = now
  return ps_cache
end

--- Return a set of PIDs whose process name is "claude".
--- @param tree table
--- @return table<number, boolean>
local function find_claude_pids(tree)
  local pids = {}
  for pid, proc in pairs(tree.by_pid) do
    if proc.name == "claude" then
      pids[pid] = true
    end
  end
  return pids
end

--- Check whether a process has a "caffeinate" child (indicates Running state).
--- @param pid number
--- @param tree table
--- @return boolean
local function has_caffeinate_child(pid, tree)
  local child_pids = tree.children[pid]
  if not child_pids then
    return false
  end
  for _, child_pid in ipairs(child_pids) do
    local child = tree.by_pid[child_pid]
    if child and child.name == "caffeinate" then
      return true
    end
  end
  return false
end

--- Send a macOS native notification via osascript.
--- @param title string
--- @param message string
local function send_notification(title, message)
  wezterm.run_child_process({
    "osascript",
    "-e",
    'display notification "' .. message .. '" with title "' .. title .. '"',
  })
end

--- Format the right status bar content.
--- @param running_count number
--- @param idle_count number
--- @return table -- wezterm.format elements
local function format_status(running_count, idle_count)
  local elements = {}
  if running_count > 0 then
    table.insert(elements, { Foreground = { Color = "#7aa2f7" } })
    table.insert(elements, { Text = "Running:" .. running_count .. " " })
  end
  if idle_count > 0 then
    table.insert(elements, { Foreground = { Color = "#9ece6a" } })
    table.insert(elements, { Text = "Idle:" .. idle_count })
  end
  return elements
end

--- Register event handlers for agent monitoring.
function M.setup()
  wezterm.on("update-right-status", function(window, _pane)
    local tree = get_process_tree()
    if not tree then
      return
    end

    local claude_pids = find_claude_pids(tree)
    if not next(claude_pids) then
      window:set_right_status("")
      return
    end

    local running_count = 0
    local idle_count = 0
    local new_states = {}

    for claude_pid, _ in pairs(claude_pids) do
      local state
      if has_caffeinate_child(claude_pid, tree) then
        state = "Running"
        running_count = running_count + 1
      else
        state = "Idle"
        idle_count = idle_count + 1
      end

      new_states[claude_pid] = state

      -- Running -> Idle transition: agent finished
      if prev_states[claude_pid] == "Running" and state == "Idle" then
        send_notification("Claude Code", "Agent task completed")
      end
    end

    prev_states = new_states
    window:set_right_status(wezterm.format(format_status(running_count, idle_count)))
  end)
end

return M
