#!/bin/bash
# require_tasks.sh - Claude Code 用 PreToolUse hook (Write|Edit)
#
# セッションに Task が 1 つも無い状態での Write/Edit を deny でブロックする。
# 「編集の前に必ず TaskCreate で作業を分解する」という規約を強制するための
# ハードゲート。以前は additionalContext による推奨だったが、非ブロッキング
# ゆえに無視できてしまうため、permissionDecision: deny へ切り替えた。
#
# Task 有無の判定は $HOME/.claude/tasks/<session_id> ディレクトリの存在で行う。
# このディレクトリは最初の TaskCreate と同時刻 (秒単位一致) に生成され、Task を
# 一度も作っていないセッションでは作られない。
#
# 当初は中の .highwatermark (割り当て済み Task ID の最大値) を読み >= 1 を要求して
# いたが、.highwatermark は TaskCreate に同期して書かれず、観測した環境では
# セッション中ずっと出現しなかった。一方で各 Task は <id>.json として TaskCreate と
# 同期生成される。.highwatermark に依存すると TaskCreate 済みでも deny され続け、
# モデルが Bash ヒアドキュメントでゲートを迂回する事象が起きた。そのため判定を
# ディレクトリの存在 (= TaskCreate が一度でも走った同期シグナル) へ変更した。
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

# このセッションで 1 つでも TaskCreate されていれば tasks ディレクトリが存在する。
tasks_dir="$HOME/.claude/tasks/$session_id"
[[ -d "$tasks_dir" ]] && exit 0

# Task が 1 つも無い — ブロックする。
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "TaskCreate なしの Write/Edit は禁止されている。\n\nファイルを編集する前に、必ず TaskCreate で作業を追跡可能なステップへ分解しなければならない。タスク未作成のままの編集は規約違反であり、この編集はブロックされた。\n\n1. TaskCreate で作業を分解する\n2. 各ステップの開始前に in_progress へ更新する\n3. 完了したら completed へ更新する\n\nいま TaskCreate を実行してから、編集をやり直すこと。"
  }
}'
