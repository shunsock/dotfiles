#!/bin/bash
# validate-bash.sh - PreToolUse hook for Claude Code
# Rejects prohibited commands with guidance on alternatives.

set -euo pipefail

# Read JSON input from stdin
input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"

# Only process Bash tool calls
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

command="$(echo "$input" | jq -r '.tool_input.command // empty')"

if [[ -z "$command" ]]; then
  exit 0
fi

# Check for prohibited commands
# awk: should use Edit tool or perl
if echo "$command" | grep -qE '\bawk\b'; then
  cat <<'EOF'
{"decision": "reject", "reason": "awk is prohibited. Use the Edit tool or perl for text processing."}
EOF
  exit 0
fi

# sed: should use Edit tool or perl
if echo "$command" | grep -qE '\bsed\b'; then
  cat <<'EOF'
{"decision": "reject", "reason": "sed is prohibited. Use the Edit tool or perl for text processing."}
EOF
  exit 0
fi

# git push: delegate to user
if echo "$command" | grep -qE '\bgit\s+push\b'; then
  cat <<'EOF'
{"decision": "reject", "reason": "git push is prohibited. Please ask the user to run git push manually."}
EOF
  exit 0
fi

# git add -A / --all / .  : require explicit file names
if echo "$command" | grep -qE '\bgit\s+add\s+(-A|--all|\.)'; then
  cat <<'EOF'
{"decision": "reject", "reason": "git add -A/--all/. is prohibited. Specify file names explicitly to avoid staging unintended files."}
EOF
  exit 0
fi
