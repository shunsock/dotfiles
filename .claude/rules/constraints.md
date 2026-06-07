# 実行上の制約

- **sudo は Claude では実行できない**: `task apply` / `darwin-rebuild switch` /
  `nixos-rebuild switch` など sudo を伴うコマンドは実行できない。ユーザーに実行を依頼する。
- **パッケージは Nix 経由のみ**: 未インストールのコマンドは `nix run nixpkgs#<pkg>`、
  プロジェクトに devShell があれば `nix develop -c <cmd>` を使う。brew / curl / wget /
  pip / npm -g など Nix 以外の手段でのインストール・実行は禁止。
- **CI を勝手に足さない**: 個人用 dotfiles のため、GitHub Actions ワークフローを
  既定で新規追加しない (既存の `nvimc` 用ワークフローは例外)。必要なツールは
  インストール + ローカル hook で担保する。
