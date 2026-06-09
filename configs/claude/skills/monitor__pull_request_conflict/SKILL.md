---
name: monitor__pull_request_conflict
description: >-
  Trigger after a PR is created or its base branch may have advanced. Polls the
  PR's mergeability (`gh pr view --json mergeable,mergeStateStatus`) until GitHub
  finishes computing it. On a CONFLICTING result, autonomously invokes the
  rescue__pull_request_conflict skill to resolve the conflict, then re-checks. No
  user confirmation is required.
tools: Bash, Read
model: inherit
---

You are an expert PR-conflict monitor. This skill owns the **detection loop**: it
polls whether a PR has a merge conflict with its base branch and, when it does,
delegates the actual resolution to the `rescue__pull_request_conflict` skill, then
re-checks. It does NOT resolve conflicts itself — detection and repair are kept
separate on purpose.

No user confirmation is required at any phase. This skill triggers and runs
autonomously.

## Responsibility boundary

- **This skill (monitor)**: poll the PR's mergeable state, classify it
  (MERGEABLE / CONFLICTING / UNKNOWN), count iterations, decide when to stop.
- **`rescue__pull_request_conflict` (repair)**: identify and integrate conflicted
  files, commit, and push. Invoked by this skill when a conflict is detected.

GitHub computes mergeability asynchronously, so `mergeable` is often `UNKNOWN`
immediately after a push or PR creation. Polling until it resolves is this skill's
job.

## Execution Steps

### Phase 1: Resolve the PR and poll until mergeability is computed

```bash
BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr view "$BRANCH" --json number --jq '.number')

# GitHub computes mergeability async; poll until it is no longer UNKNOWN.
# Poll every 10 seconds, up to 2 minutes (12 iterations).
for i in $(seq 1 12); do
  MERGEABLE=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable' 2>&1)
  if [ "$MERGEABLE" != "UNKNOWN" ]; then
    break
  fi
  sleep 10
done

gh pr view "$PR_NUMBER" --json mergeable,mergeStateStatus
```

### Phase 2: Classify the outcome

- **MERGEABLE** (no conflict) → report that the PR merges cleanly and exit.
- **UNKNOWN after the poll window** → report that GitHub has not finished computing
  mergeability and exit (the user can re-run later).
- **CONFLICTING** → go to Phase 3.

### Phase 3: Delegate resolution, then re-check

On `CONFLICTING`, invoke the **`rescue__pull_request_conflict`** skill (via the Skill
tool). That skill identifies the conflicted files, integrates both sides, commits,
and pushes. It does not poll — it hands control back here.

After `rescue__pull_request_conflict` returns, increment the iteration counter and
return to Phase 1 to re-check mergeability on the updated branch.

**Iteration limit: maximum 3 monitor↔repair cycles.** (Conflicts can reappear if the
base advances again mid-resolution, but a low bound prevents an unbounded loop.)

- If the PR becomes MERGEABLE within the limit → Phase 4.
- If the limit is reached still CONFLICTING → report the still-conflicted files and
  stop for manual intervention.

### Phase 4: Output summary

```
## PR Conflict Monitor Summary

### Result
- Status: MERGEABLE / STILL_CONFLICTING / UNKNOWN
- Iterations: N/3
- PR: #<number>

### Resolved Files (if any repairs ran)
- path/to/file
```

## Prohibited Actions

- Do NOT ask the user for confirmation at any phase.
- Do NOT resolve conflicts here — delegate repair to `rescue__pull_request_conflict`.
- Do NOT use `git push --force` or `git push -f`.
- Do NOT loop forever — honor the 3-iteration limit.
