#!/bin/bash
# validate-bash.sh - PreToolUse hook for Claude Code
# Rejects prohibited commands with guidance on alternatives.
#
# Rules are declared as data arrays. To add a new rule, append one line
# to COMMAND_RULES or PATTERN_RULES — no logic changes needed.

set -euo pipefail

# ── Section 1: Rule definitions ──────────────────────────────────────
# Format: "command::reason"  — \b word boundaries are added automatically
COMMAND_RULES=(
  "awk::awk is prohibited. Use the Edit tool or perl for text processing."
  "sed::sed is prohibited. Use the Edit tool or perl for text processing."
)

# Format: "regex_pattern::reason"  — passed to grep -qE as-is
PATTERN_RULES=(
  '\bgit\s+push\b::git push is prohibited. Please ask the user to run git push manually.'
  '\bgit\s+add\s+(-A|--all|\.)::git add -A/--all/. is prohibited. Specify file names explicitly to avoid staging unintended files.'
)

# ── Section 2: Functions ─────────────────────────────────────────────
reject_with_reason() {
  local reason="$1"
  jq -n --arg reason "$reason" '{"decision": "reject", "reason": $reason}'
  exit 0
}

check_command_rules() {
  local cmd="$1"
  for entry in "${COMMAND_RULES[@]}"; do
    local pattern="${entry%%::*}"
    local reason="${entry#*::}"
    if echo "$cmd" | grep -qE "\\b${pattern}\\b"; then
      reject_with_reason "$reason"
    fi
  done
}

check_pattern_rules() {
  local cmd="$1"
  for entry in "${PATTERN_RULES[@]}"; do
    local pattern="${entry%%::*}"
    local reason="${entry#*::}"
    if echo "$cmd" | grep -qE "$pattern"; then
      reject_with_reason "$reason"
    fi
  done
}

# ── Section 3: Main ──────────────────────────────────────────────────
input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

command="$(echo "$input" | jq -r '.tool_input.command // empty')"
if [[ -z "$command" ]]; then
  exit 0
fi

check_command_rules "$command"
check_pattern_rules "$command"
