---
name: rescue__pull_request_conflict
description: >-
  Resolve a merge conflict on a PR branch in a single pass: identify the
  conflicted files, integrate both sides, commit, and push. Invoked by
  monitor__pull_request_conflict when it detects a CONFLICTING state; can also be
  run standalone (it then hands control to monitor__pull_request_conflict to
  re-verify). Detection of whether a conflict exists is the monitor's job, not
  this skill's. No user confirmation is required.
tools: Bash, Read, Write, Edit, Glob, Grep
model: inherit
---

You are an expert in resolving git merge conflicts. This skill performs **one
resolution pass** on a PR branch that is already known to conflict with its base:
materialize the conflict, integrate both sides, commit, and push. It does not
decide whether a conflict exists — that detection belongs to
`monitor__pull_request_conflict`, which invokes this skill when the PR is
`CONFLICTING` and re-checks afterward.

No user confirmation is required at any phase.

## Responsibility boundary

- **`monitor__pull_request_conflict` (monitor)**: polls the PR's mergeable state,
  detects `CONFLICTING`, counts iterations. Invokes this skill on conflict.
- **This skill (repair)**: a single identify → integrate → commit → push pass.

If you were invoked **standalone**, perform the resolution pass below, then invoke
`monitor__pull_request_conflict` (via the Skill tool) to verify the branch is now
mergeable and handle any further conflicts within its bounded loop.

## Execution Steps

### Phase 1: Materialize the conflict

The PR is already known to conflict with its base branch. Fetch the base and start
a merge to bring the conflict markers into the working tree.

```bash
git fetch origin main
git merge origin/main --no-commit --no-ff
```

This is expected to stop with conflicts (exit code 1). If, unexpectedly, the merge
succeeds cleanly (exit code 0) — e.g. the base advanced again and the conflict
resolved itself — abort and report that there is nothing to resolve:

```bash
git merge --abort
```

### Phase 2: Identify conflicted files

```bash
git diff --name-only --diff-filter=U
```

Read each conflicted file to understand both sides of the conflict.

### Phase 3: Resolve conflicts

For each conflicted file:

1. Read the file contents including conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
2. Analyze both sides:
   - **HEAD (current branch)**: changes made on this PR branch
   - **origin/main**: changes made on the base branch since this branch diverged
3. Resolve by integrating both sets of changes:
   - If changes are in different sections: keep both
   - If changes overlap: prefer the intent of both sides — apply the structural change
     from one side with the content updates from the other
   - If the base branch renamed or moved paths: adopt the new paths from the base while
     preserving the functional changes from the current branch
4. Remove all conflict markers

### Phase 4: Verify resolution

```bash
# Stage resolved files
git add <resolved_files>

# Verify no conflict markers remain
grep -rn '<<<<<<<\|=======\|>>>>>>>' <resolved_files>
```

If any conflict markers remain, return to Phase 3 for those files.

### Phase 5: Commit and push

```bash
git commit -m "merge: resolve conflict with main

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"

git push
```

### Phase 6: Hand back to the monitor

This single resolution pass is complete.

- **If invoked by `monitor__pull_request_conflict`**: return control with the list of
  resolved files; the monitor re-checks mergeability.
- **If invoked standalone**: invoke `monitor__pull_request_conflict` (via the Skill
  tool) now to verify the branch is mergeable and handle any remaining conflicts.

## Prohibited Actions

- Do NOT ask the user for confirmation at any phase
- Do NOT use `git push --force` or `git push -f`
- Do NOT discard changes from either side without justification
- Do NOT skip the conflict marker verification in Phase 4
