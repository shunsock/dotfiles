---
name: update__nix_darwin
description: >-
  ユーザーが nix-darwin (macOS システム設定) の依存を更新したいときに起動する。
  `nix-darwin/` で `task update` を実行して flake.lock を更新し、専用ブランチを
  切ってコミットし push する。flake 依存の更新を 1 つの自律フローにまとめる。
tools: Bash
model: inherit
---

あなたは nix-darwin の依存更新を担当する。このスキルは `nix-darwin/` の flake 依存を
更新し、専用ブランチに切ってコミット・push するまでを **1 つの自律フロー** として実行する。

`task update` は内部で `nix flake update` を実行し、`nix-darwin/flake.lock` を更新する。
**flake.lock の差分が出ない (= 更新がない) 場合は、ブランチを切らずにその旨を報告して終了する。**

## 実行上の制約

- このスキルは **`task apply` を実行しない**。apply は sudo を伴い Claude では実行できない
  ため、適用はユーザーに依頼する (PR マージ後に手動で `task apply`)。
- `git push --force` / `git push -f` は使わない。

## 実行ステップ

### フェーズ 1: 更新の実行

リポジトリルートから `nix-darwin/` に移動し、flake 依存を更新する。

```bash
cd nix-darwin
task update
```

### フェーズ 2: 差分の確認

`flake.lock` に変更があるか確認する。

```bash
git -C "$(git rev-parse --show-toplevel)" status --porcelain nix-darwin/flake.lock
```

- 出力が空 (差分なし) → 更新は不要。ブランチを切らずに「更新なし」と報告して終了。
- 差分あり → フェーズ 3 へ。

### フェーズ 3: ブランチ作成・コミット・push

直近の運用に合わせ、ブランチ名・コミットメッセージは `bump/nix` 系で統一する。

```bash
cd "$(git rev-parse --show-toplevel)"
git switch -c bump/nix
git add nix-darwin/flake.lock
git commit -m "bump: update nix"
git push -u origin bump/nix
```

> 既に `bump/nix` ブランチが存在する場合は、日付などでサフィックスを付けて衝突を避ける
> (例: `bump/nix-20260627`)。

### フェーズ 4: 報告

更新された input (例: `nixpkgs`, `nix-darwin`, `home-manager` など) を `flake.lock` の
差分から要約し、push したブランチ名とともにユーザーへ報告する。PR 作成やマージ後の
`task apply` (ユーザーが手動実行) を案内する。
