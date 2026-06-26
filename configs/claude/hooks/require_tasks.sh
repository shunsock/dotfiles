#!/bin/bash
# require_tasks.sh - Claude Code 用 PreToolUse hook (Write|Edit)
#
# in_progress な Task が 1 つも無い状態での Write/Edit を deny でブロックする。
# 「編集を始める前に、その作業を担う Task を in_progress にする」という規約を
# 強制するハードゲート。これにより「捨て Task を 1 つ作れば以降ずっと編集し放題」
# という抜け穴を塞ぐ — 編集を続けるには常に in_progress な Task が要る。
#
# 判定は $HOME/.claude/tasks/<session_id>/<id>.json の .status を直接読む。
# 実機検証の結果、アクティブセッション中は以下が成り立つ:
#   - TaskCreate が <id>.json を同期生成し status="pending" を書く
#   - TaskUpdate が同 json の .status を同期更新する (in_progress / completed)
#   - status="deleted" にすると json ごと削除される
# よって編集の瞬間の「現在 in_progress な Task」をディスクから確実に判定できる。
#
# 過去に試した .highwatermark (割り当て済み Task ID の最大値) は、アクティブ
# セッション中は書かれず終了時に遅延生成されると判明したため依存しない。
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

# 現在 in_progress な Task が 1 つでもあれば許可する。
tasks_dir="$HOME/.claude/tasks/$session_id"
if [[ -d "$tasks_dir" ]]; then
  for task_json in "$tasks_dir"/*.json; do
    [[ -f "$task_json" ]] || continue
    status="$(jq -r '.status // empty' "$task_json" 2>/dev/null)"
    [[ "$status" == "in_progress" ]] && exit 0
  done
fi

# in_progress な Task が無い — ブロックする。
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "in_progress な Task が無い状態での Write/Edit は禁止されている。\n\nファイルを編集する前に、その編集を担う Task を必ず in_progress にしなければならない。in_progress な Task が 1 つも無いままの編集は規約違反であり、この編集はブロックされた。\n\n1. まだ Task が無ければ TaskCreate で作業を分解する\n2. これから着手するステップの Task を TaskUpdate で in_progress にする\n3. そのステップが完了したら completed にする\n\nいま該当 Task を in_progress にしてから、編集をやり直すこと。"
  }
}'
