---
paths:
  - "nix-darwin/**"
---

# nix-darwin (macOS)

対象: aarch64-darwin (Apple Silicon)。コマンドは `nix-darwin/` で実行する。

## 編集後の検証 (必須)

- `task format` — フォーマット統一
- `task validate` — build + check の総合検証

## 適用 (sudo, Claude 実行不可 → ユーザーに依頼)

- `task apply` — 設定を反映
- 直接実行する場合は build (現在ユーザー) → `sudo darwin-rebuild switch`
  (prebuilt な result バイナリ経由) の 2 段。Nix 評価を sudo 下で走らせない。

構造の詳細は `nix-darwin/README.md` を参照。
