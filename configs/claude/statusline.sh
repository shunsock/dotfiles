#!/bin/bash
# Claude Code statusline script
# Displays: model | context usage bar | cost | duration | git branch

input=$(cat)

# Model
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Context window usage
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
BAR_WIDTH=15
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
if [ "$FILLED" -gt 0 ]; then
  printf -v FILL "%${FILLED}s"
  BAR="${FILL// /▓}"
fi
if [ "$EMPTY" -gt 0 ]; then
  printf -v PAD "%${EMPTY}s"
  BAR="${BAR}${PAD// /░}"
fi

# Color context bar based on usage
if [ "$PCT" -ge 80 ]; then
  CTX_COLOR="\033[31m" # red
elif [ "$PCT" -ge 50 ]; then
  CTX_COLOR="\033[33m" # yellow
else
  CTX_COLOR="\033[32m" # green
fi
RESET="\033[0m"

# Cost
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")

# Duration
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

# Git branch
CWD=$(echo "$input" | jq -r '.workspace.current_dir // "."')
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
if [ -n "$BRANCH" ]; then
  GIT_PART=" | ${BRANCH}"
else
  GIT_PART=""
fi

printf "%b" "${MODEL} | ${CTX_COLOR}${BAR} ${PCT}%${RESET} | ${COST_FMT} | ${MINS}m${SECS}s${GIT_PART}\n"
