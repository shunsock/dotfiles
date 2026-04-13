#!/bin/bash
# recommend-tasks.sh - PreToolUse hook for Claude Code
# Sends a notify message before every Write/Edit call,
# recommending Claude to use TaskCreate for progress tracking.

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

jq -n '{
  "decision": "notify",
  "message": "[TASK RECOMMENDATION] You are about to write or edit a file. If you have not created Tasks yet, use TaskCreate now to:\n1. Break down your work into trackable steps\n2. Mark tasks as in_progress before starting each step\n3. Mark tasks as completed when done\n\nThis helps the user understand your progress and ensures structured work."
}'
