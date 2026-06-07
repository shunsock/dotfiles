#!/bin/bash
# recommend-nix-validation.sh - PostToolUse hook (Write|Edit|MultiEdit)
#
# nix-darwin の Nix 設定 (*.nix, config/, module/) を編集した後に、
# nix-darwin で `task format` と `task validate` を実行するよう促す。
#
# スコープは nix-darwin 配下に限定する (task-list フックと揃える)。リポジトリ直下の
# .claude/settings.json は repo 全体に適用されフックをパスで宣言的に絞れないため、
# スクリプト側で対象を自衛 (self-guard) し、nix-darwin 以外では何もしない。
#
# "notify" decision は会話にテキストを注入するだけでツール実行を強制しない。
# 実際に検証を走らせるかは Claude の判断に委ねる (適用 = sudo は別途ユーザー依頼)。

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
case "$tool_name" in
  Write | Edit | MultiEdit) ;;
  *) exit 0 ;;
esac

file_path="$(echo "$input" | jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

# nix-darwin 配下のファイルのみを対象とする。
case "$file_path" in
  */nix-darwin/* | nix-darwin/*) ;;
  *) exit 0 ;;
esac

# Nix 設定ファイルのみを対象にする (*.nix または config/ module/ 配下)。
is_nix_config=false
case "$file_path" in
  *.nix) is_nix_config=true ;;
  */config/* | */module/*) is_nix_config=true ;;
esac
[[ "$is_nix_config" == "false" ]] && exit 0

jq -n '{
  "decision": "notify",
  "message": ("[ACTION RECOMMENDED] nix-darwin の Nix 設定を編集しました。コミット前に "
    + "nix-darwin/ で検証を実行してください:\n\n  cd nix-darwin && task format && task validate\n\n"
    + "(task apply は sudo が必要なため Claude では実行できません。反映が必要な場合はユーザーに依頼してください)")
}'
