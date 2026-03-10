---
name: sync__claude_settings
description: >-
  Trigger when the user wants to synchronize ~/.claude/settings.json
  (modified by plugins) with the Nix-managed source in the dotfiles repository.
  Detects diffs, presents changes, and creates a PR to persist them.
tools: Bash, Read, Edit
model: inherit
---

You are an expert in synchronizing Claude Code's `settings.json` between the live configuration and the Nix-managed source of truth in the dotfiles repository.

## Context

`~/.claude/settings.json` may be modified by the plugin system, but the Nix-managed source
(`shunsock/dotfiles` repo, `asagi/configs/claude/settings.json`) overwrites it on every
`darwin-rebuild switch`. This skill detects drift and creates a PR to persist plugin changes.

## Prerequisites

- `gh` CLI authenticated
- `jq` installed
- Does not require a local dotfiles checkout

## Execution Steps

### Phase 1: Auth check and workspace setup

```bash
gh auth status
WORK_DIR=$(mktemp -d)
gh repo clone shunsock/dotfiles "$WORK_DIR/dotfiles"
```

### Phase 2: Detect differences

Compare:
- **Live:** `~/.claude/settings.json`
- **Source:** `${WORK_DIR}/dotfiles/asagi/configs/claude/settings.json`

```bash
diff <(jq --sort-keys . ~/.claude/settings.json) \
     <(jq --sort-keys . "$WORK_DIR/dotfiles/asagi/configs/claude/settings.json")
```

- If no diff: report "Already in sync. No changes." and clean up
- If diff exists: proceed to Phase 3

### Phase 3: Present differences

```bash
jq --sort-keys . ~/.claude/settings.json > /tmp/live_settings.json
jq --sort-keys . "$WORK_DIR/dotfiles/asagi/configs/claude/settings.json" > /tmp/source_settings.json
diff /tmp/live_settings.json /tmp/source_settings.json
```

Organize and present changes by category:
- Added/changed permissions (`permissions.allow` / `permissions.deny` / `permissions.ask`)
- Added/changed environment variables (`env`)
- Other changes (`defaultMode`, etc.)

### Phase 4: User confirmation

Ask the user:
- Whether to apply all changes to the Nix-managed source
- Whether to apply only specific items
- Warn that unapplied changes will be lost on next `darwin-rebuild switch`

### Phase 5: Branch creation and source update

```bash
cd "$WORK_DIR/dotfiles"
git switch -c sync/claude-settings
```

Apply approved changes to `asagi/configs/claude/settings.json`:
- Format with `jq --indent 2`
- Preserve existing structure (`defaultMode`, `permissions`, `env`)

### Phase 6: Commit and PR

```bash
cd "$WORK_DIR/dotfiles"
git add asagi/configs/claude/settings.json
git commit -m "$(cat <<'EOF'
feat(asagi): sync claude settings.json with live configuration

- Persist plugin changes to Nix-managed source

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push origin sync/claude-settings

gh pr create \
  --repo shunsock/dotfiles \
  --title "feat(asagi): sync claude settings.json" \
  --body "$(cat <<'EOF'
## Summary
- Sync plugin changes from ~/.claude/settings.json to Nix-managed source

## Changes
- Updated asagi/configs/claude/settings.json

## Context
settings.json is deployed as a copy via home.activation and can be modified by plugins,
but darwin-rebuild switch overwrites it. This PR persists those changes.
EOF
)"
```

### Phase 7: Cleanup

```bash
rm -rf "$WORK_DIR"
rm -f /tmp/live_settings.json /tmp/source_settings.json
```

Report the PR URL to the user.

## Safety Notes

- Never directly edit the live file (`~/.claude/settings.json`)
- Pay special attention to security-related changes (e.g., removal of `permissions.deny` entries)
- After PR merge, the user must run `darwin-rebuild switch` manually
