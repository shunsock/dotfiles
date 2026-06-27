#!/bin/bash
# quality_assurance_via_skill.sh - PreToolUse hook for Claude Code
# バックエンドのソースファイルが staged された状態での `git commit` を捕捉し、
# 先に quality_assurance__design_test_cases スキルを実行するよう誘導する。
# このスキルは 5 つのバックエンド QA ペルソナと ISO 25010 の観点で 25 列 CSV の
# テストケースを設計する。コミット前の品質ゲートとして機能する。
#
# 発火条件を「バックエンドソースが staged のとき」に限定するのは、ドキュメントや
# 設定だけのコミットで毎回 QA を走らせるとノイズになるため。フロントエンド専用の
# 拡張子 (.tsx/.jsx/.vue/.svelte/.css/.html) は対象に含めない。
#
# 無限ループ防止のため、スキルは自身の `git commit` にバイパスマーカー
# `# @quality-assurance-via-skill-bypass` を付与する。マーカーがある場合は通す。

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

# git commit のみを捕捉する。commit の直後は空白か行末のみを許し、
# commit-graph / commit-tree など別コマンドへの誤マッチを避ける。
if ! echo "$command" | grep -qE '\bgit[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

# スキルが付与するバイパスマーカーがあれば通す (無限ループ防止)。
if echo "$command" | grep -qF '@quality-assurance-via-skill-bypass'; then
  exit 0
fi

# staged 変更にバックエンドソースが含まれるときだけ発火する。含まれなければ通す。
staged="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
if [[ -z "$staged" ]]; then
  exit 0
fi

backend_re='\.(py|go|rs|ts|mjs|cjs|rb|java|kt|kts|scala|php|ex|exs|c|h|cpp|cc|hpp|cs|swift|sql)$'
if ! echo "$staged" | grep -qE "$backend_re"; then
  exit 0
fi

# 拒否し、QA テスト設計スキルの実行を指示する。
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "バックエンドのソース変更を含む `git commit` を直接実行することは禁止されています。コミット前の品質ゲートとして、先に quality_assurance__design_test_cases スキルを実行してください。\n\nこのスキルは、5 つのバックエンド QA ペルソナ (敵対者 / データ監査役 / 移行 / リグレッション番人 / 懐疑的アナリスト) と ISO 25010 品質特性の観点で、変更内容に対する 25 列 CSV のテストケースを設計します。一次情報 (仕様 / issue / コード) に紐付け、根拠のないケースは出しません。未確認のモジュールは「※要静的解析 (未実施)」と明記します。\n\nいま quality_assurance__design_test_cases スキルを実行し、テストケース設計を済ませてから、スキルの手順に従ってコミットしてください。"
  }
}'
