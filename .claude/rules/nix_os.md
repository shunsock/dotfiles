---
paths:
  - "nix-os/**"
---

# nix-os (NixOS / Linux)

対象: x86_64-linux。コマンドは `nix-os/` で実行する。

## 編集後の検証 (必須)

- `task format` — フォーマット統一
- `task validate` — build + check の総合検証

## 適用 (sudo, Claude 実行不可 → ユーザーに依頼)

- `task apply` (`sudo nixos-rebuild switch --flake .#myNixOS`)
