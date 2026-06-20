#!/bin/bash
# clean-comment-out.sh - Claude Code 用 PostToolUse hook
# ソースファイルへの Write/Edit の後に、clean__comment_out スキルの実行を促す
# 必須指示を注入する。これにより、意味のないコメントやコメントアウトされた
# デッドコードが削除され、価値あるコメント (Why / 設計判断 /
# TODO|FIXME|HACK|XXX マーカー / 公開インターフェースのドキュメント) は残る。
#
# additionalContext による注入は会話へ文章を追加するだけで、ツール実行を
# 強制しない。そのためメッセージは明示的な指示で書く。
#
# 注入は hookSpecificOutput.additionalContext で行う。
# see: https://code.claude.com/docs/en/hooks#posttooluse-decision-control
#
# 非ソースファイル (設定 / ドキュメント / データ) はスキップする。コメント整理は
# コードコメントが対象であり、すべての Write/Edit (例: markdown, json) で発火
# させるとノイズになるため。

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

# ソースコードファイルのみで発火する。コメント整理の判断 (Why か What か、
# デッドコード、ドキュメントコメント、マーカー) はプログラミング言語に適用され、
# 設定 / ドキュメント / データファイルには適用されないため。
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

# コメント整理ワークフローの実行を促す必須指示を出力する。
jq -n --arg path "$file_path" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ("ソースファイルが Write/Edit されました: " + $path + "\n\n[必須アクション] いま変更したファイルに対して、ただちに clean__comment_out スキルを実行しなければならない。省略してはならない。ユーザーへの確認も不要である。\n\nclean__comment_out スキルは、意味のないコメントとコメントアウトされたデッドコードを削除し、価値あるコメントは残す。いま次を適用すること:\n1. いま編集したファイルのコメントを洗い出す。\n2. 削除する: コードを見れば自明な内容 (What) を述べただけのコメント、コメントアウトされた古いコード (デッドコード)。\n3. 残す: なぜ (Why) を説明するコメント (設計判断 / 制約 / トレードオフ)、TODO/FIXME/HACK/XXX マーカー、公開インターフェースのドキュメントコメント。\n4. 迷ったらコメントを残す。\n5. コメントのみを編集する — コードの挙動は変えず、いま変更したファイルだけを対象にする。\n\nいま編集したファイルのコメント整理が完了するまで、他のタスクへ進んではならない。")
  }
}'
