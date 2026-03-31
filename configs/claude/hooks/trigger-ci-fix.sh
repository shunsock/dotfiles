#!/bin/bash
# trigger-ci-fix.sh - PostToolUse hook for Claude Code
# After `git push` or `gh pr create`, injects a message to trigger the
# flow__ci_fix skill so that CI failures are automatically monitored and
# fixed without user intervention.

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

command="$(echo "$input" | jq -r '.tool_input.command // empty')"
if [[ -z "$command" ]]; then
  exit 0
fi

# Check if the command is a git push or gh pr create
is_git_push=false
is_gh_pr_create=false

if echo "$command" | grep -qE '\bgit\s+push\b'; then
  is_git_push=true
fi

if echo "$command" | grep -qE '\bgh\s+pr\s+create\b'; then
  is_gh_pr_create=true
fi

if [[ "$is_git_push" == "false" && "$is_gh_pr_create" == "false" ]]; then
  exit 0
fi

# Check if the tool execution succeeded (exit code 0)
exit_code="$(echo "$input" | jq -r '.tool_output.exit_code // .tool_output.exitCode // "0"')"
if [[ "$exit_code" != "0" ]]; then
  exit 0
fi

# Emit a message to trigger the CI fix skill
jq -n '{
  "decision": "notify",
  "message": "A push or PR creation was detected. Automatically triggering the flow__ci_fix skill to monitor CI status and fix failures if any. Execute the skill now."
}'
