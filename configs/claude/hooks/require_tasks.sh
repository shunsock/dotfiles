#!/bin/bash
# require_tasks.sh - Claude Code 用 PreToolUse hook (Write|Edit)
#
# セッションに Task が 1 つも無い状態での Write/Edit を deny でブロックする。
# 「編集の前に必ず TaskCreate で作業を分解する」という規約を強制するための
# ハードゲート。以前は additionalContext による推奨だったが、非ブロッキング
# ゆえに無視できてしまうため、permissionDecision: deny へ切り替えた。
#
# Task 有無の判定は $HOME/.claude/tasks/<session_id>/.highwatermark を見る。
# この環境では Task は per-session の JSON ファイルとしてではなく、ロックと
# 採番ハイウォーターマーク (.highwatermark) のみがこのディレクトリに置かれる。
# .highwatermark は割り当て済み Task ID の最大値で、1 つでも TaskCreate すると
# 1 以上になり、Task 未作成のセッションではディレクトリ自体が作られない。
# session_id を得る環境変数は無いため、ペイロード stdin が唯一の取得元である。
# see: https://code.claude.com/docs/en/hooks#pretooluse-decision-control

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

# session_id が取れない場合は、別セッションやサブエージェントの状態で
# 誤ってブロックしないよう、安全側に倒して許可する。
session_id="$(echo "$input" | jq -r '.session_id // empty')"
[[ -z "$session_id" ]] && exit 0

# 計画立案そのものは止めない。plan ファイルの作成は編集前の安全なステップで
# あり、Task の存在を要求すると plan モードが自身の plan を書けなくなる。
file_path="$(echo "$input" | jq -r '.tool_input.file_path // empty')"
case "$file_path" in
  */.claude/plans/*) exit 0 ;;
esac

# このセッションで 1 つでも Task が採番されていれば (.highwatermark >= 1) 許可。
highwatermark_file="$HOME/.claude/tasks/$session_id/.highwatermark"
if [[ -f "$highwatermark_file" ]]; then
  highwatermark="$(cat "$highwatermark_file" 2>/dev/null || echo 0)"
  if [[ "$highwatermark" =~ ^[0-9]+$ ]] && (( highwatermark >= 1 )); then
    exit 0
  fi
fi

# Task が 1 つも無い — ブロックする。
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "TaskCreate なしの Write/Edit は禁止されている。\n\nファイルを編集する前に、必ず TaskCreate で作業を追跡可能なステップへ分解しなければならない。タスク未作成のままの編集は規約違反であり、この編集はブロックされた。\n\n1. TaskCreate で作業を分解する\n2. 各ステップの開始前に in_progress へ更新する\n3. 完了したら completed へ更新する\n\nいま TaskCreate を実行してから、編集をやり直すこと。"
  }
}'
