#!/bin/bash
# pr_submission_via_skill.sh - PreToolUse hook for Claude Code
# Rejects direct `gh pr create` calls and instructs Claude to use the
# submit__pull_request skill instead, which generates a structured,
# narrative-style PR description automatically.
#
# The submit__pull_request skill marks its own `gh pr create` invocation with
# the bypass marker `# @pr-submission-via-skill-bypass` so that this hook does
# not block it, avoiding an infinite rejection loop.

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

# Allow through if the command contains the bypass marker from submit__pull_request
if echo "$command" | grep -qF '@pr-submission-via-skill-bypass'; then
  exit 0
fi

# Reject and instruct to use the narrative PR workflow
jq -n '{
  "decision": "reject",
  "reason": "Direct `gh pr create` is not allowed. Use the submit__pull_request skill instead, which generates a narrative-style PR description (概要, 背景, 課題, 目標, 採用手法, 変更箇所, 妥協と制限, 検証方法, 確認事項, 参考文献) and then monitors CI automatically.\n\nExecute the submit__pull_request skill now to create this PR with a proper narrative description."
}'
