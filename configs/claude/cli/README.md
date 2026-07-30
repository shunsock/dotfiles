# Claude Code CLI ツール

hook から起動される .NET file-based app を置く。
ソースは `configs/claude/cli/` にある。
home-manager の `home.file` が `~/.claude/cli/` へ配布する。
hook は stdin の JSON ペイロードを解釈するイベント駆動として書く。
CLI は引数でファイルを受け取る純粋なフィルタとして書く。
この分離により、hook 以外 (手動実行・スクリプト) からも利用できる。

## CLI 一覧

| CLI | 役割 |
|---|---|
| `check_japanese_stop_word.cs` | 指定ファイルを 1 行ずつ走査し、`stop_word.csv` の禁止語彙を検出して stderr へ言い換え先を提案する |

## check_japanese_stop_word.cs

```bash
dotnet run ~/.claude/cli/check_japanese_stop_word.cs -- <file> [<file>...]
dotnet run ~/.claude/cli/check_japanese_stop_word.cs -- --csv <path> <file>...
```

- 終了コード: `0` = 検出なし / `1` = 検出あり / `2` = 引数誤り。
- 検出結果は `ファイル:行: 語彙と言い換え先 — 該当行の抜粋` の形式で stderr へ出す。
- 語彙は `~/.claude/skills/reference/japanese_stop_word/stop_word.csv` が single source of truth。形式はヘッダ行 + `禁止語彙,言い換え先` の 2 列で、`--csv` で差し替えられる。
- 長い語彙を優先して照合する。部分文字列の関係にある語彙で同じ箇所を二重に報告しないためである。
