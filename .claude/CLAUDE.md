# CLAUDE.md

Nix を中心とした個人 dotfiles リポジトリ。全体像と完全なコマンド一覧は `README.md` を参照。

プロジェクト別の詳細ルールは `.claude/rules/` にトピック分割して配置している。
`nix-darwin/` `nix-os/` `nvimc/` `configs/claude/skills/` 配下のファイルを編集すると、
対応するルールがパススコープで自動的にロードされる
(`repo_map.md` と `constraints.md` は常時ロード)。

## Claude 設定のソース管理 (メタ構造)

`configs/claude/` は、この環境の **グローバル Claude Code 設定 (`~/.claude/`) の
single source of truth**。`nix-darwin/module/claude.nix` または
`nix-os/modules/claude.nix` が home-manager の `home.file` で `~/.claude/` 配下へ
配布する (どちらの環境で構築するかによる)。

| ソース (`configs/claude/`) | 配布先 (`~/.claude/`) |
|---|---|
| `CLAUDE.md` | グローバルルール (全プロジェクト共通) |
| `settings.json` | 権限 / 環境変数 / hooks |
| `agents/` | サブエージェント定義 |
| `skills/` | カスタムスキル定義 |
| `hooks/` | フック用シェルスクリプト |
| `rules/` | トピック別ルール |
| `statusline.sh` | ステータスライン |

### 注意

- `configs/claude/` を編集しても **即座には反映されない**。構築している環境に応じて
  `nix-darwin/` または `nix-os/` で `task apply` (sudo, Claude 実行不可) を行い、
  配布先のストアを再生成する必要がある。
- `configs/claude/CLAUDE.md` や `settings.json` の変更は **全プロジェクトの挙動** に影響する。慎重に。
- これ (本リポジトリ専用の `.claude/`) とグローバル設定ソース (`configs/claude/`) は別物。混同しない。
