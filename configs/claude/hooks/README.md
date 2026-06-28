# Claude Code フック

Claude Code の hook 実装。`configs/claude/settings.json` の `hooks` で登録され、
home-manager 経由で `~/.claude/hooks/` へ配布される。`configs/claude/` はグローバル
設定のソースであり、変更の反映には `task apply` が必要 (詳細はリポジトリの CLAUDE.md
を参照)。

## 実行方式 — .NET file-based app

各フックは単一の `.cs` ファイルで、`dotnet run <hook>.cs` で実行する (AOT ビルドは
しない)。「1 フック = 単一ファイルで動く」ことを .NET 採用の主目的に置いた設計判断に
よる。共有モジュールを持たないため、複数フックで必要な小さなロジック (例: 対象拡張子
の読み込み) は各ファイルにミラーされる。

## additionalContext の性質

多くのフックは `hookSpecificOutput.additionalContext` に文字列を注入して動作を促す。
この注入は会話へ文章を追加するだけで、**ツール実行を強制しない**。そのためメッセージ
は「〜しなければならない」という明示的な指示として書く。PreToolUse でツール自体を
ブロックする場合は `permissionDecision: deny` を使う (additionalContext の誘導とは別系統)。

SEE: https://code.claude.com/docs/en/hooks#posttooluse-decision-control

## フック一覧

| フック | イベント (matcher) | 役割 |
|---|---|---|
| `validate_bash.cs` | PreToolUse (Bash) | 禁止コマンドを拒否し代替を案内する |
| `pr_submission_via_skill.cs` | PreToolUse (Bash) | `gh pr create` の直接実行を拒否し submit__pull_request へ誘導する |
| `quality_assurance_via_skill.cs` | PreToolUse (Bash) | バックエンドが staged な `git commit` を捕捉し QA スキルへ誘導する |
| `require_tasks.cs` | PreToolUse (Write\|Edit) | in_progress な Task が無い状態の編集を deny でブロックする |
| `trigger_ci_fix.cs` | PostToolUse (Bash) | `git push` / `gh pr create` 成功後に monitor__ci_status を促す |
| `write_structured_comment.cs` | PostToolUse (Write\|Edit) | ソース編集後に write__structured_comment を促す |
| `clean_comment_out.cs` | PostToolUse (Write\|Edit) | ソース編集後に clean__comment_out を促す |
| `block_stop_on_open_tasks.cs` | Stop | 未完了 Task が残ったままの停止をブロックする |

## コメント整理フック (writer → cleaner)

`write_structured_comment.cs` と `clean_comment_out.cs` は対で動く。`settings.json` の
`Write|Edit` matcher で writer を cleaner より前に登録し、ソース編集時に
**write (構造化) → clean (掃除)** の順で発火させる。

- **writer**: デフォルトはコメント 0。コードに表現できない知識 (未完の事実・外部世界
  の事実) だけを whitelist マーカーで書く。
- **cleaner**: 意味のないコメントとデッドコードを削除し、価値あるコメントを残す。
- 両者が扱うマーカー語彙は単一の定義を共有するため、**writer が書いたコメントに
  cleaner をかけても no-op** になる。

共有する定義の置き場:

- マーカー語彙・フォーマット・契約: `~/.claude/skills/template/comment_markers.md`
- 対象拡張子: `~/.claude/skills/reference/comment_out_skills_target/extensions.csv`
