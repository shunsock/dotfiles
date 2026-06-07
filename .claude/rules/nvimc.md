---
paths:
  - "nvimc/**"
---

# nvimc (Docker 開発コンテナ)

Ubuntu 24.04 ベースの携帯可能な開発環境コンテナ。コマンドは `nvimc/` で実行する。

- ビルド: `task build:default:arm` / `task build:default:amd` / `task build:python`
- 実行: `task run:default:arm <workspace>` など (workspace パスを渡す)
- バージョンは `Taskfile.yml` の `VERSION` 変数で管理。レジストリは `tsuchiya55docker/nvimc`。
- デプロイは GitHub Actions の手動トリガ。Docker 操作は環境次第で手動実行が必要な場合がある。
