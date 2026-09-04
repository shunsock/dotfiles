# CLAUDE.md

開発用 Docker コンテナ `nvimc` を管理するリポジトリ。全体像と完全なコマンド一覧は `README.md` を参照。

プロジェクト別の詳細ルールは `.claude/rules/` にトピック分割して配置している。`nvimc/` 配下を編集すると、対応するルールがパススコープで自動的にロードされる (`repo_map.md` と `constraints.md` は常時ロード)。

## 移設済みの内容

Nix によるマシン構成とグローバル Claude 設定 (`~/.claude/` の single source of truth) は
[shunsock/devtools](https://github.com/shunsock/devtools) が持つ。
このリポジトリでは扱わない。

| 移設前 | 移設先 (devtools) |
|---|---|
| `nix-darwin/` | `nix-darwin-laptop/` |
| `nix-os/` | `nix-os-laptop/` |
| `configs/` | `nix-config-common/` |
