#!/bin/bash
# clean-comment-out.sh - PostToolUse hook for Claude Code
# After a Write or Edit on a source file, injects a mandatory instruction to
# execute the clean__comment_out skill so that meaningless comments and
# commented-out dead code are removed while valuable comments (Why / design
# rationale / TODO|FIXME|HACK|XXX markers / public-interface docs) are kept.
#
# The message uses explicit instructions because the "notify" decision only
# injects text into the conversation — it does not force tool execution.
#
# Non-source files (config / docs / data) are skipped: the cleanup concerns
# code comments, and triggering on every Write/Edit (e.g. markdown, json)
# would produce noise.

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

file_path="$(echo "$input" | jq -r '.tool_input.file_path // empty')"
if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only trigger on source-code files. Comment-cleanup judgment (Why vs What,
# dead code, doc comments, markers) applies to programming languages, not to
# config / docs / data files.
case "$file_path" in
  *.rs | *.go | *.py | *.ts | *.tsx | *.js | *.jsx | *.java | *.kt | *.kts \
    | *.c | *.h | *.cpp | *.cc | *.hpp | *.cs | *.rb | *.php | *.swift \
    | *.scala | *.sh | *.bash | *.zsh | *.lua | *.ex | *.exs | *.hs \
    | *.ml | *.dart | *.nix)
    ;;
  *)
    exit 0
    ;;
esac

# Emit a mandatory instruction to execute the comment-cleanup workflow.
jq -n --arg path "$file_path" '{
  "decision": "notify",
  "message": ("A source file was just written or edited: " + $path + "\n\n[MANDATORY ACTION REQUIRED] You MUST now execute the clean__comment_out skill on the file(s) you just changed. Do NOT skip this. Do NOT ask the user for confirmation.\n\nThe clean__comment_out skill removes meaningless comments and commented-out dead code, while keeping valuable comments. Apply it now:\n1. Identify the comments in the file(s) you just edited.\n2. DELETE: comments restating what the code obviously does (What), and commented-out old code (dead code).\n3. KEEP: comments explaining WHY (rationale / constraints / tradeoffs), TODO/FIXME/HACK/XXX markers, and public-interface documentation comments.\n4. When in doubt, keep the comment.\n5. Edit only comments — never change code behavior, and only touch files you just modified.\n\nDo NOT continue with other tasks until the comment cleanup of the just-edited file(s) is complete.")
}'
