#!/bin/bash
# recommend-tasks.sh - Claude Code 用 PreToolUse hook
# Write/Edit の実行前に、TaskCreate での進捗管理を促すメッセージを注入する。
#
# 注入は hookSpecificOutput.additionalContext で行う。これは exit 0 時に
# PreToolUse が解釈する唯一の「非ブロッキングなコンテキスト注入」フィールドで、
# ツール実行を止めずに Claude へ文章を届ける。
# 旧実装は存在しない "decision": "notify" を返しており、Claude Code から
# 黙って無視されていた (notify という decision は仕様上どのイベントにも無い)。
# see: https://code.claude.com/docs/en/hooks#pretooluse-decision-control

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "[ERROR] TaskCreate なしの Write/Edit は禁止されている。\n\nファイルを編集する前に、必ず TaskCreate で作業を追跡可能なステップへ分解しなければならない。タスク未作成のままの編集は規約違反である。\n\n1. TaskCreate で作業を分解する\n2. 各ステップの開始前に in_progress へ更新する\n3. 完了したら completed へ更新する\n\nまだタスクを作成していないなら、ただちに編集を中断し、いま TaskCreate を実行すること。"
  }
}'
