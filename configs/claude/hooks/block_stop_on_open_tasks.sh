#!/bin/bash
# block_stop_on_open_tasks.sh - Claude Code 用 Stop hook
#
# 未完了 (pending / in_progress) の Task が残ったままの停止をブロックする。
# require_tasks.sh (編集前に in_progress を要求する PreToolUse ゲート) と対で
# 機能し、「捨て Task を 1 つ in_progress にして放置」を防ぐ。停止しようとした
# 時点で未完了 Task があれば、それらを片付ける (実作業を行う) まで停止できない。
#
# Task 状態は $HOME/.claude/tasks/<session_id>/<id>.json の .status を読む。
# 形式と同期性は require_tasks.sh のヘッダコメント参照。
# see: https://code.claude.com/docs/en/hooks#stop-and-subagentstop-decision-control

set -euo pipefail

input="$(cat)"

# stop_hook_active が true の停止は、この hook 自身のブロックで再入した停止で
# ある。ここで再びブロックすると無限ループになるため許可する。
if echo "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

# session_id が取れない場合は、別セッションの状態で誤ってブロックしないよう
# 安全側に倒して許可する。
session_id="$(echo "$input" | jq -r '.session_id // empty')"
[[ -z "$session_id" ]] && exit 0

tasks_dir="$HOME/.claude/tasks/$session_id"
[[ -d "$tasks_dir" ]] || exit 0

# 未完了 Task (pending / in_progress) を subject 付きで集める。
incomplete=""
for task_json in "$tasks_dir"/*.json; do
  [[ -f "$task_json" ]] || continue
  line="$(jq -r 'select(.status == "pending" or .status == "in_progress") | "- [\(.status)] \(.subject)"' "$task_json" 2>/dev/null)"
  [[ -n "$line" ]] && incomplete+="$line"$'\n'
done

[[ -z "$incomplete" ]] && exit 0

reason="未完了の Task が残っている:
${incomplete}
各 Task は実際に作業を行って解決すること (作業せずに completed にしてはならない)。すべて片付けてから停止し直すこと。"

jq -n --arg reason "$reason" '{
  "decision": "block",
  "reason": $reason
}'
