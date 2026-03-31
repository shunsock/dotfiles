#!/bin/bash
# trigger-ci-fix.sh - PostToolUse hook for Claude Code
# After `git push` or `gh pr create`, injects a mandatory instruction to
# execute the flow__ci_fix skill so that CI failures are automatically
# monitored and fixed without user intervention.
#
# The message uses explicit, step-by-step instructions because the "notify"
# decision only injects text into the conversation — it does not force tool
# execution. Concrete instructions maximize the likelihood that Claude will
# act on the message immediately.

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

# Build a contextual trigger description
if [[ "$is_gh_pr_create" == "true" ]]; then
  trigger_context="A PR was just created."
else
  trigger_context="Commits were just pushed to the PR branch."
fi

# Emit a mandatory instruction to execute the CI fix workflow.
jq -n --arg ctx "$trigger_context" '{
  "decision": "notify",
  "message": ($ctx + "\n\n[MANDATORY ACTION REQUIRED] You MUST now execute the flow__ci_fix skill immediately. Do NOT skip this. Do NOT ask the user for confirmation. This is required by the project rules in CLAUDE.md.\n\nExecute these steps NOW:\n1. Get the current branch and PR number:\n   BRANCH=$(git branch --show-current)\n   PR_NUMBER=$(gh pr view \"$BRANCH\" --json number --jq \".number\")\n2. Wait for CI checks to be registered (poll for up to 60 seconds)\n3. Poll CI status every 30 seconds until all checks complete (timeout: 30 min)\n4. If all checks pass, report success\n5. If any check fails, read logs with: gh run view <run_id> --log-failed\n6. Diagnose the failure, fix the code, commit, and push\n7. Repeat from step 2 (max 5 iterations)\n\nDo NOT continue with any other task until this CI monitoring workflow is complete.")
}'
