---
name: flow__ci_fix
description: >-
  Trigger after creating or pushing to a GitHub PR. Monitors CI (GitHub Actions)
  status, and if any check fails, reads the logs, fixes the code, commits, and
  pushes. Repeats until all CI checks pass. No user confirmation is required —
  Claude triggers and executes this entire process autonomously.
tools: Bash, Read, Write, Edit, Glob, Grep
model: inherit
---

You are an expert CI troubleshooter. This skill runs automatically after a PR is
created or after pushing commits to a PR branch. No user confirmation is required
at any phase — Claude autonomously triggers and completes this entire workflow.

## Context

After a PR is created or updated, GitHub Actions CI checks may fail due to lint
errors, test failures, type errors, formatting issues, or build problems. This
skill monitors CI status, diagnoses failures from logs, applies fixes, and
pushes updated code until all checks pass.

**Important**: This entire process requires NO user confirmation. Claude
autonomously triggers this skill after PR creation or push, and all phases
execute automatically without asking the user for approval.

## Execution Steps

### Phase 1: Wait for CI to start

After a PR is created or commits are pushed, wait for CI checks to begin.

```bash
# Get the current branch and PR number
BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr view "$BRANCH" --json number --jq '.number')

# Wait for checks to be registered (max 60 seconds)
for i in $(seq 1 12); do
  STATUS=$(gh pr checks "$PR_NUMBER" 2>&1 || true)
  if echo "$STATUS" | grep -qE '(pass|fail|pending)'; then
    break
  fi
  sleep 5
done
```

### Phase 2: Monitor CI status

Poll CI status until all checks complete. **Do NOT use `gh pr checks --watch`** — it
blocks indefinitely and will hit tool timeouts on long-running CI pipelines.

Instead, use a polling loop with explicit timeout:

```bash
# Poll every 30 seconds, timeout after 30 minutes (60 iterations)
MAX_POLLS=60
POLL_INTERVAL=30

for i in $(seq 1 $MAX_POLLS); do
  CHECKS=$(gh pr checks "$PR_NUMBER" 2>&1)
  if ! echo "$CHECKS" | grep -q "pending"; then
    break
  fi
  if [ "$i" -eq "$MAX_POLLS" ]; then
    echo "TIMEOUT: CI checks still pending after 30 minutes"
    break
  fi
  sleep $POLL_INTERVAL
done
```

After the loop exits, inspect the result:
- If all checks pass → report success and exit
- If any check failed → proceed to Phase 3
- If timed out with checks still pending → report timeout to the user and exit

### Phase 3: Diagnose failures

For each failed check:

1. Identify the failed job name and run ID:
   ```bash
   gh pr checks "$PR_NUMBER"
   ```

2. Fetch the failed job logs:
   ```bash
   gh run view <run_id> --log-failed
   ```

3. Analyze the log output to identify:
   - Which files are affected
   - What type of error occurred (lint, test, type, build, format)
   - The specific error messages and line numbers

### Phase 4: Apply fixes

Based on the diagnosis:

- **Lint errors**: Read the affected files and fix the reported issues
- **Test failures**: Read the failing test and the source code, then fix the bug or update the test
- **Type errors**: Fix type annotations or type mismatches
- **Formatting issues**: Run the project's formatter if identifiable, or fix manually
- **Build errors**: Fix compilation or dependency issues

After applying fixes, verify locally if possible:
- Check if a `Makefile`, `package.json` scripts, `Cargo.toml`, or similar build config exists
- Run the relevant local check commands to confirm the fix before pushing

### Phase 5: Commit and push

```bash
git add <fixed_files>
git commit -m "fix: resolve CI failures

- <summary of fixes applied>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

git push
```

### Phase 6: Re-monitor CI

Return to Phase 1 and repeat the cycle. Continue until:
- All CI checks pass → report success and exit
- The iteration limit is reached → report remaining failures and stop

## Iteration Limit

- Maximum **5 fix-and-push cycles**
- If CI does not pass within 5 iterations, report the remaining failures to the user with:
  - Which checks are still failing
  - What fixes were attempted
  - The latest error logs
  - Suggested next steps for manual intervention

## Output Format

After all checks pass (or iteration limit is reached), produce a summary:

```
## CI Fix Summary

### Result
- Status: ALL_PASSED / NEEDS_ATTENTION
- Iterations: N/5
- PR: #<number>

### Fix History
| Iteration | Failed Check        | Root Cause             | Fix Applied                |
|-----------|---------------------|------------------------|----------------------------|
| 1         | lint                | unused import          | removed unused import      |
| 2         | test-unit           | assertion mismatch     | updated expected value     |

### Remaining Failures (if iteration limit reached)
- <check name>: <error summary>
- Suggested: <manual action>
```

## Prohibited Actions

- Do NOT ask the user for confirmation at any phase
- Do NOT use `git push --force` or `git push -f`
- Do NOT modify files unrelated to the CI failure
- Do NOT skip the log analysis — always read logs before attempting a fix
- Do NOT blindly retry without making changes — each iteration must include a meaningful fix attempt
- Do NOT delete or disable CI checks/tests to make them pass
