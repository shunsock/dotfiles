---
name: code_inspect__complexity
description: >-
  code_inspect の複雑度チェックサブスキル。認知的複雑度を complexity CLI で定量評価し、
  計算量 (時間・空間複雑度) を定性的に評価する。
  親スキル code_inspect から呼び出される。直接呼び出さないこと。
tools: Read, Bash
---

## 観点の定義

レビュー対象ファイルの「複雑さ」を以下の 2 軸で評価する。

- **認知的複雑度**: コードを読んで理解するのに必要な認知負荷 (定量、CLI で計測)
- **計算量**: 時間複雑度・空間複雑度・データ構造選択の妥当性 (定性)

## 評価手順

### Step 1: 認知的複雑度の計測 (定量)

[thoughtbot/complexity](https://github.com/thoughtbot/complexity) CLI を使う。
インデントベースのヒューリスティックでコードの読みにくさを数値化する。

```bash
nix run nixpkgs#complexity -- --format json <対象ファイル or ディレクトリ>
```

#### 判定基準

- スコア **15 以下**: 問題なし (SonarSource の推奨上限)
- スコア **16〜25**: should レベルで指摘
- スコア **26 以上**: must レベルで指摘

#### CLI が利用できない場合

`nix run` が失敗した場合は、出力の「所見」に以下を記載してスキップする。

```
complexity CLI が利用できないため、認知的複雑度の定量チェックをスキップしました。
`nix run nixpkgs#complexity` で実行可能です。
```

定性チェック (Step 2) は継続する。

### Step 2: 計算量の定性チェック

レビュー対象ファイルを Read し、以下の観点で評価する。

#### 時間複雑度

- ネストしたループが同じコレクションを走査していないか (O(n²) リスク)
- ループ内で繰り返し線形探索をしていないか
- 不要な再計算がループ内にないか (ループ外にホイストできないか)

#### 空間複雑度

- 大きなデータ構造の不要なコピーがないか
- 配列を全マテリアライズせずイテレータ/ジェネレータで処理できないか

#### データ構造選択

- メンバシップチェックに list を使っていないか (set にすべき)
- キー検索に線形探索していないか (dict/map にすべき)
- 順序が要らないところで list を使っていないか (set / dict)

#### 判定基準

- 明らかな O(n²) で n が大きくなり得る箇所: must
- データ構造選択の改善余地: should
- 微小な最適化余地: nit

## 出力契約

`.claude/skills/code_inspect/template/inspect_output.md` の規約に従う。
観点名は `complexity`。
