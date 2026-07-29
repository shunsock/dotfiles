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
| `require_tasks.cs` | PreToolUse (Write\|Edit) | in_progress な Task が無い状態の編集を deny でブロックする (plans/ と scratchpad は除外) |
| `trigger_ci_fix.cs` | PostToolUse (Bash) | `git push` / `gh pr create` 成功後に monitor__ci_status を促す |
| `write_structured_comment.cs` | PostToolUse (Write\|Edit) | ソース編集後に write__structured_comment を促す |
| `clean_comment_out.cs` | PostToolUse (Write\|Edit) | ソース編集後に clean__comment_out を促す |
| `validate_comment_format.cs` | PostToolUse (Write\|Edit) | コメントを走査し語彙・2行・80文字・issue番号の違反を検出して修正を促す |
| `validate_japanese_stop_word.cs` | PreToolUse (Bash) | `git commit` / `gh pr create` の前に変更ファイルの不自然な日本語語彙を検出し deny で書き直しを指示する |
| `block_stop_on_open_tasks.cs` | Stop | 未完了 Task が残ったままの停止をブロックする |

## Task 必須フック (require_tasks.cs)

`$HOME/.claude/tasks/<session_id>/*.json` を走査し in_progress な Task が 1 つも
無い状態の Write/Edit を deny でブロックする。判定対象外は次の 2 つ:

- `/.claude/plans/` を含むパス — 計画メモは作業単位を持たない
- `/private/tmp/claude-` から始まるパス — scratchpad は作業単位を持たない

TaskCreate/TaskUpdate ツールが利用できないハーネスでも編集を再開できるよう、deny
メッセージ (`permissionDecisionReason`) に task json を直接作成する `mkdir` + `printf`
の実行例を埋め込んでいる。session_id は hook が stdin ペイロードから取得しメッセージに
差し込むため、そのままコピーして実行すれば in_progress な Task を宣言できる。

## コメント整理フック (writer → cleaner → validator)

`write_structured_comment.cs`・`clean_comment_out.cs`・`validate_comment_format.cs` は
3 段で動く。`settings.json` の `Write|Edit` matcher にこの順で登録し、ソース編集時に
**write (構造化) → clean (掃除) → validate (検証)** の順で発火させる。

- **writer**: デフォルトはコメント 0。コードに表現できない知識 (未完の事実・外部世界
  の事実・ユーザーの明示指示) だけを whitelist マーカーで書く。
- **cleaner**: whitelist マーカーで始まらない非 doc コメントをすべて削除し、マーカー付き
  コメントと doc コメントだけを残す。
- **validator**: 編集後のコメントを機械的に走査し、(1) 語彙マーカー始まり (2) 2 行以内
  (3) 80 文字以内 (4) issue/PR 番号なし、の違反を検出して修正を強制する。doc コメントと
  先頭のモジュールヘッダは免除する。writer/cleaner の誘導 (additionalContext) が守られた
  かを機械的に裏取りする最終ゲート。
- 3 者が同じ whitelist を共有するため、**writer が書いたコメントに cleaner・validator を
  かけても no-op** になる。

共有する定義の置き場:

- マーカー語彙・フォーマット・契約 (人間・スキル向け): `~/.claude/skills/template/comment_markers.md`
- 対象拡張子 (3 hook が共有するため外部ファイルに切り出す): `~/.claude/skills/reference/comment_out_skills_target/extensions.csv`

マーカー語彙の機械可読な形は validator (`validate_comment_format.cs`) 内の const が
持つ。読者がこの 1 フックだけなので外部ファイルにせず const とした。対象拡張子は
3 hook が参照するため、file-based app では共有 const を持てず外部ファイルに切り出す
(各ファイルの読み込みロジックはミラーされる)。

## 日本語 stop word フック (validate_japanese_stop_word.cs)

AI が下書きした日本語の不自然な語彙を commit / PR 作成の前に検出するゲート。
hook 本体は発火判定と deny だけを担う。
走査は専用 CLI `~/.claude/cli/check_japanese_stop_word.cs` へ委譲する。

- **発火条件**: Bash コマンドが `git commit` または `gh pr create` を含むとき。
- **走査対象**: `git commit` は staged な変更を走査する。`gh pr create` は `origin/HEAD` (無ければ `origin/main`) との diff を走査する。対象拡張子はコメント対象言語 (`extensions.csv`) + `.md` `.markdown` `.txt`。
- **語彙の定義**: `~/.claude/skills/reference/japanese_stop_word/stop_word.csv` が single source of truth。行を足せば hook と CLI の挙動が同時に変わる。
- **検出時**: `permissionDecision: deny` でコマンドをブロックする。検出結果 (ファイル:行: 語彙と言い換え先) と書き直しの指示を返す。
- **fail open**: git・dotnet・CLI が使えない環境ではブロックせず素通しする。品質ゲートを単一障害点にしないためである。
