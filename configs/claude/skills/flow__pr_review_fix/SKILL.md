---
name: flow__pr_review_fix
description: >-
  Trigger after reviewers (human or AI) leave comments on a GitHub PR.
  Reads review comments, applies requested code changes, commits, and pushes.
  Repeats for each round of review feedback. No user confirmation is required —
  Claude triggers and executes this entire process autonomously.
tools: Bash, Read, Write, Edit, Glob, Grep
model: inherit
---

You are an expert at addressing PR review feedback. This skill runs automatically
when review comments are detected on a PR. No user confirmation is required at
any phase — Claude autonomously triggers and completes this entire workflow.

## Context

After a PR is created, reviewers (human teammates, GitHub Copilot, CodeRabbit,
or other AI review tools) may leave comments requesting changes. This skill
fetches those comments, understands the requested changes, applies fixes to the
code, and pushes updated commits. It handles both inline code comments and
general PR-level review comments.

**Important**: This entire process requires NO user confirmation. Claude
autonomously triggers this skill when review comments are detected, and all
phases execute automatically without asking the user for approval.

## Execution Steps

### Phase 1: Fetch review comments

Identify the current PR and retrieve all pending review comments.

```bash
BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr view "$BRANCH" --json number --jq '.number')

# Fetch all review comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews --jq '.[] | select(.state != "APPROVED")'

# Fetch inline comments (review comments on specific lines)
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments
```

Also check for general PR comments:
```bash
gh pr view "$PR_NUMBER" --comments
```

### Phase 2: Categorize and prioritize comments

For each comment, determine:

1. **Source**: Human reviewer or AI tool (Copilot, CodeRabbit, etc.)
2. **Type**:
   - **Code change request**: Specific code modification requested on a file/line
   - **Question**: Reviewer asking for clarification (respond with a reply comment)
   - **Suggestion**: Optional improvement (apply if reasonable)
   - **Approval/praise**: No action needed
   - **Nit**: Minor style/preference issue (apply the fix)
3. **Scope**: Which files and lines are affected
4. **Already addressed**: Skip comments on lines that have already been modified in subsequent commits

Process comments in this priority order:
1. Human reviewer code change requests (highest priority)
2. Human reviewer questions (reply with explanation)
3. AI tool code change requests
4. Suggestions and nits (lowest priority)

### Phase 3: Apply fixes

For each actionable comment:

1. Read the affected file and understand the surrounding context
2. Understand the reviewer's intent — not just the literal words, but what improvement they want
3. Apply the change:
   - For inline suggestions with code blocks: apply the suggested code
   - For descriptive requests: implement the change that matches the reviewer's intent
   - For questions: read the relevant code, then reply with a clear explanation via comment
4. If a comment is ambiguous or contradicts another comment, prefer the human reviewer's intent

For replying to questions:
```bash
gh pr comment "$PR_NUMBER" --body "$(cat <<'EOF'
> <quoted original question>

<clear, concise answer explaining the code's intent or design decision>
EOF
)"
```

For replying to inline comments after fixing:
```bash
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/<comment_id>/replies \
  -f body="Fixed in the latest commit."
```

### Phase 4: Verify fixes locally

Before pushing, run available local checks:

- Look for `Makefile`, `package.json`, `Cargo.toml`, `pyproject.toml`, or similar
- Run lint, type-check, and test commands if available
- If local verification fails, fix the issue before proceeding

### Phase 5: Commit and push

Group related fixes into logical commits:

```bash
git add <fixed_files>
git commit -m "fix: address review feedback

- <summary of changes per reviewer comment>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

git push
```

### Phase 6: Verify CI after push

After pushing, monitor CI status briefly:

**Do NOT use `gh pr checks --watch`** — it blocks indefinitely and will hit tool
timeouts on long-running CI pipelines. Use a polling loop instead:

```bash
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

If CI fails after the review fixes, diagnose and fix (follow the same approach as flow__ci_fix).

## Iteration Limit

- Maximum **3 review-fix cycles** per skill invocation
- A cycle is: fetch comments → apply fixes → push → verify
- If unresolved comments remain after 3 cycles, report to the user with:
  - Which comments could not be addressed
  - Why they could not be resolved (ambiguous, conflicting, requires design decision)
  - Suggested approach for manual resolution

## Handling Special Cases

### Conflicting reviews
If two reviewers give contradictory feedback, prefer the human reviewer over AI,
and if both are human, apply the suggestion that aligns better with the existing
codebase patterns. Note the conflict in the commit message.

### "Request changes" reviews
When a reviewer submits a review with "Request changes" status, prioritize all
comments from that review as they block merging.

### AI-generated suggestions with code blocks
GitHub Copilot and CodeRabbit often include exact code suggestions in markdown
code blocks. Apply these directly when they are correct and consistent with the
codebase style.

### Dismissed reviews
Skip comments from reviews that have been dismissed.

## Output Format

After addressing all comments (or iteration limit is reached), produce a summary:

```
## PR Review Fix Summary

### Result
- Status: ALL_ADDRESSED / NEEDS_ATTENTION
- Cycles: N/3
- PR: #<number>

### Comments Addressed
| # | Reviewer       | Type           | File:Line          | Action Taken          |
|---|----------------|----------------|--------------------|-----------------------|
| 1 | @reviewer      | change request | src/main.rs:42     | refactored function   |
| 2 | CodeRabbit     | suggestion     | src/lib.rs:15      | applied suggestion    |
| 3 | @reviewer      | question       | src/utils.rs:88    | replied with explanation |

### Unresolved Comments (if any)
- Comment by @X: "<summary>" — Reason: <why not resolved>
```

## Prohibited Actions

- Do NOT ask the user for confirmation at any phase
- Do NOT use `git push --force` or `git push -f`
- Do NOT dismiss or resolve review threads without addressing them
- Do NOT ignore human reviewer comments in favor of AI suggestions
- Do NOT delete or revert code changes that reviewers explicitly requested
- Do NOT add unrelated changes while addressing review feedback
- Do NOT reply rudely or dismissively to any reviewer comment
