#!/bin/bash
# enforce-narrative-pr.sh - PreToolUse hook for Claude Code
# Rejects direct `gh pr create` calls and instructs Claude to use the
# flow__submit_pr skill instead, which generates narrative-style PR
# descriptions automatically.
#
# The flow__submit_pr skill marks its own `gh pr create` invocation with
# the bypass marker `# @narrative-pr-bypass` so that this hook does not
# block it, avoiding an infinite rejection loop.

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

# Only intercept gh pr create commands
if ! echo "$command" | grep -qE '\bgh\s+pr\s+create\b'; then
  exit 0
fi

# Allow through if the command contains the bypass marker from flow__submit_pr
if echo "$command" | grep -qF '@narrative-pr-bypass'; then
  exit 0
fi

# Reject and instruct to use the narrative PR workflow
jq -n '{
  "decision": "reject",
  "reason": "Direct `gh pr create` is not allowed. Use the flow__submit_pr skill instead, which generates a narrative-style PR description (Background, Approach, What Changed, Tradeoffs, Testing, Review Guide) and then monitors CI automatically.\n\nExecute the flow__submit_pr skill now to create this PR with a proper narrative description."
}'
