# リポジトリ構成

開発用 Docker コンテナを管理するリポジトリ。

| ディレクトリ | 対象 | ビルドツール |
|---|---|---|
| `nvimc/` | 開発用 Docker コンテナ | Taskfile + Docker |
| `document/` | 品質保証記録 | — |

作業は対象ディレクトリで実行する。コマンドの詳細は `.claude/rules/nvimc.md` を参照。

Nix によるマシン構成とグローバル Claude 設定は
[shunsock/devtools](https://github.com/shunsock/devtools) へ移設した。

リポジトリ全体の説明と完全なコマンド一覧は `README.md` にある。
