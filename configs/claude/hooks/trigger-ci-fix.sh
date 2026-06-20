#!/bin/bash
# trigger-ci-fix.sh - Claude Code 用 PostToolUse hook
# `git push` または `gh pr create` の後に、monitor__ci_status スキルの実行を
# 促す必須指示を注入する。これにより CI の失敗がユーザー介入なしに監視・修正
# される。監視と修正のループは monitor__ci_status が所有し、各修復パスは
# rescue__ci_failure へ委譲される。
#
# additionalContext による注入は会話へ文章を追加するだけで、ツール実行を
# 強制しない。そのため、Claude が即座に行動する確度を上げるよう、メッセージは
# 明示的かつ段階的な手順で書く。
#
# 注入は hookSpecificOutput.additionalContext で行う。旧実装は存在しない
# "decision": "notify" を返しており、Claude Code から黙って無視されていた
# (notify という decision は hook 仕様にそもそも存在しない)。
# see: https://code.claude.com/docs/en/hooks#posttooluse-decision-control

set -euo pipefail

input="$(cat)"

tool_name="$(echo "$input" | jq -r '.tool_name // empty')"
if [[ "$tool_name" != "Bash" ]]; then
  exit 0
fi

command="$(echo "$input" | jq -r '.tool_input.command // empty')"
if [[ -z "$command" ]]; then
  exit 0
fi

# コマンドが git push か gh pr create かを判定する
is_git_push=false
is_gh_pr_create=false

if echo "$command" | grep -qE '\bgit\s+push\b'; then
  is_git_push=true
fi

if echo "$command" | grep -qE '\bgh\s+pr\s+create\b'; then
  is_gh_pr_create=true
fi

if [[ "$is_git_push" == "false" && "$is_gh_pr_create" == "false" ]]; then
  exit 0
fi

# ツール実行が成功したか (exit code 0) を確認する
exit_code="$(echo "$input" | jq -r '.tool_output.exit_code // .tool_output.exitCode // "0"')"
if [[ "$exit_code" != "0" ]]; then
  exit 0
fi

# 発火コンテキストの説明文を組み立てる
if [[ "$is_gh_pr_create" == "true" ]]; then
  trigger_context="PR が作成されました。"
else
  trigger_context="PR ブランチへ commit が push されました。"
fi

# CI 修正ワークフローの実行を促す必須指示を出力する。
jq -n --arg ctx "$trigger_context" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ($ctx + "\n\n[必須アクション] ただちに monitor__ci_status スキルを実行しなければならない。省略してはならない。ユーザーへの確認も不要である。これは CLAUDE.md のプロジェクト規約で要求されている。\n\nmonitor__ci_status スキルは監視と修正のループを所有し、CI をポーリングして失敗時には各修復パスで rescue__ci_failure を起動する。いま次の手順を実行すること:\n1. 現在のブランチと PR 番号を取得する:\n   BRANCH=$(git branch --show-current)\n   PR_NUMBER=$(gh pr view \"$BRANCH\" --json number --jq \".number\")\n2. CI チェックが登録されるまで待つ (最大 60 秒ポーリング)\n3. 全チェック完了まで 30 秒ごとに CI 状態をポーリングする (タイムアウト: 30 分)\n4. 全チェックがパスしたら成功を報告する\n5. いずれかが失敗したら rescue__ci_failure を起動する (gh run view <run_id> --log-failed でログを読み、コードを修正し、commit して push する)\n6. 手順 2 から繰り返す (最大 5 回)\n\nこの CI 監視ワークフローが完了するまで、他のタスクへ進んではならない。")
  }
}'
