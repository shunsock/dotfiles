# 実行上の制約

- **パッケージは Nix 経由のみ**: 未インストールのコマンドは `nix run nixpkgs#<pkg>` で実行する。devShell があれば `nix develop -c <cmd>` を使う。brew / curl / wget / pip / npm -g による導入は禁止。
- **CI を勝手に足さない**: 個人用リポジトリのため GitHub Actions を既定で新規追加しない。既存の `nvimc` 用ワークフローは例外とする。必要なツールはローカル hook で担保する。
- **Docker 操作は環境次第**: コンテナのビルドと実行は Docker デーモンの状態に依存する。失敗したらユーザーに実行を依頼する。
