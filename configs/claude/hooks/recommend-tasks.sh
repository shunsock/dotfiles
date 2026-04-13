#!/bin/bash
# recommend-tasks.sh - PreToolUse hook for Claude Code
# Sends a notify message before every Write/Edit call,
# requiring Claude to use TaskCreate for progress tracking.

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

jq -n '{
  "decision": "notify",
  "message": "[MANDATORY ACTION REQUIRED] You MUST use TaskCreate before writing or editing files. If you have not created Tasks yet, stop and create them NOW.\n\n1. Break down your work into trackable steps with TaskCreate\n2. Mark tasks as in_progress before starting each step\n3. Mark tasks as completed when done\n\nDo NOT proceed with Write/Edit without Tasks."
}'
