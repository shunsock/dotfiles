#!/bin/bash
# recommend-task-list.sh - PreToolUse hook (Bash)
#
# 特定の task を実行する直前に、まず `task -l` でタスク一覧と正確な名前を
# 確認するよう促す。Taskfile はディレクトリごとに異なるため、思い込みで
# 存在しないタスク名を叩くのを防ぐ。
#
# スコープは nix-darwin 配下に限定する。リポジトリ直下の .claude/settings.json は
# repo 全体に適用されフックをパスで宣言的に絞れないため、スクリプト側で対象を
# 自衛 (self-guard) し、nix-darwin 以外では何もしない。
#
# "notify" decision は会話にテキストを注入するだけでツール実行を強制しない。

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
[[ "$tool_name" != "Bash" ]] && exit 0

command="$(echo "$input" | jq -r '.tool_input.command // empty')"
[[ -z "$command" ]] && exit 0

# task をコマンドの先頭位置で呼んでいるか (行頭 / ; / & / | の直後)。
# ファイル名等に含まれる "task" を誤検知しないため位置で判定する。
if ! echo "$command" | grep -qE '(^|[;&|])[[:space:]]*task([[:space:]]|$)'; then
  exit 0
fi

# 既に一覧表示 (task -l / --list) の場合は促さない。
if echo "$command" | grep -qE '(^|[;&|])[[:space:]]*task[[:space:]]+(-l|--list)([[:space:]]|$)'; then
  exit 0
fi

# nix-darwin スコープ: コマンドが nix-darwin を対象にしている (例: cd nix-darwin && task ...)、
# または実行ディレクトリ (cwd) が nix-darwin 配下のときのみ対象とする。
cwd="$(echo "$input" | jq -r '.cwd // empty')"
in_nix_darwin=false
if echo "$command" | grep -qE '(^|[/[:space:]])nix-darwin([/[:space:]]|$)'; then
  in_nix_darwin=true
fi
case "$cwd" in
  */nix-darwin | */nix-darwin/*) in_nix_darwin=true ;;
esac
[[ "$in_nix_darwin" == "false" ]] && exit 0

jq -n '{
  "decision": "notify",
  "message": "[ACTION RECOMMENDED] 特定の task を実行する前に、まず同じディレクトリで `task -l` を実行し、利用可能なタスクと正確な名前を確認してください。確認済みであればそのまま実行して構いません。"
}'
