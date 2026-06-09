---
name: monitor__ci_status
description: >-
  Trigger after a PR is created or commits are pushed to a PR branch. Polls
  GitHub Actions CI until all checks complete. On failure, autonomously invokes
  the rescue__ci_failure skill to apply one fix-commit-push pass, then
  re-monitors. Owns the monitor-and-fix loop and its iteration limit. No user
  confirmation is required.
tools: Bash, Read
model: inherit
---

You are an expert CI monitor. This skill owns the **monitoring loop**: it polls
GitHub Actions CI status and, when a check fails, delegates the actual diagnosis
and repair to the `rescue__ci_failure` skill, then re-monitors. It does NOT fix
code itself — detection and repair are kept separate on purpose.

No user confirmation is required at any phase. This skill triggers and runs
autonomously after a PR is created or commits are pushed.

## Responsibility boundary

- **This skill (monitor)**: poll CI, classify the outcome (pass / fail / timeout),
  count iterations, decide when to stop.
- **`rescue__ci_failure` (repair)**: diagnose a failed run from its logs, apply a
  single fix-commit-push pass. Invoked by this skill on each failure.

The iteration limit lives here because it bounds the **monitor↔repair loop**, not a
single repair.

## Execution Steps

### Phase 1: Resolve the PR and wait for CI to register

```bash
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

### Phase 2: Poll until all checks complete

**Do NOT use `gh pr checks --watch`** — it blocks indefinitely and will hit tool
timeouts on long-running CI pipelines. Use an explicit polling loop:

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

### Phase 3: Classify the outcome

Inspect the result of the poll:

- **All checks pass** → go to Phase 5 (success summary) and exit.
- **Timed out with checks still pending** → report the timeout to the user and exit.
- **One or more checks failed** → go to Phase 4.

### Phase 4: Delegate repair, then re-monitor

On failure, invoke the **`rescue__ci_failure`** skill (via the Skill tool). That
skill diagnoses the failed run from its logs, applies one fix, commits, and pushes.
It does not poll — it hands control back here.

After `rescue__ci_failure` returns, increment the iteration counter and return to
Phase 1 to re-monitor the new run.

**Iteration limit: maximum 5 monitor↔repair cycles.**

- If CI passes within the limit → Phase 5.
- If the limit is reached with failures remaining → report the remaining failures
  (which checks still fail, what fixes were attempted across iterations, the latest
  error logs, suggested manual next steps) and stop.

### Phase 5: Output summary

```
## CI Monitor Summary

### Result
- Status: ALL_PASSED / NEEDS_ATTENTION / TIMEOUT
- Iterations: N/5
- PR: #<number>

### Fix History (if any repairs ran)
| Iteration | Failed Check | Root Cause          | Fix Applied             |
|-----------|--------------|---------------------|-------------------------|
| 1         | lint         | unused import       | removed unused import   |
| 2         | test-unit    | assertion mismatch  | updated expected value  |

### Remaining Failures (if iteration limit reached)
- <check name>: <error summary>
- Suggested: <manual action>
```

## Prohibited Actions

- Do NOT ask the user for confirmation at any phase.
- Do NOT use `gh pr checks --watch`.
- Do NOT diagnose or edit code here — delegate repair to `rescue__ci_failure`.
- Do NOT loop forever — honor the 5-iteration limit.
- Do NOT delete or disable CI checks to make them pass.
