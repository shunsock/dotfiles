# リポジトリ構成

Nix を中心とした個人 dotfiles。独立した 3 つのサブプロジェクトで構成される。

| ディレクトリ | 対象 | ビルドツール |
|---|---|---|
| `nix-darwin/` | macOS (Apple Silicon) システム設定 | Taskfile + flake |
| `nix-os/` | Linux (NixOS) システム設定 | Taskfile + flake |
| `nvimc/` | 開発用 Docker コンテナ | Taskfile + Docker |
| `configs/` | グローバル設定のソース (claude / zsh) | — |

各サブプロジェクトは独立しており、それぞれ専用の Taskfile と flake を持つ。
作業は対象ディレクトリで実行する。コマンドの詳細は各 `.claude/rules/<project>.md` を参照。

リポジトリ全体の説明と完全なコマンド一覧は `README.md` にある。
