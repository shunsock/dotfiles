---
name: code_inspect
description: >-
  コードレビューの Phase 2 (技術レビュー) を担当するサブオーケストレーター。
  7 観点 (complexity / readability / consistency / design / security /
  testability / error_handling) のサブスキルを並列に起動し、指摘を集約する。
  親スキル code_review から呼び出されるか、評価のみが欲しい場合は単独でも起動できる。
tools: Read, Bash, AskUserQuestion, Task
---

## 概要

このスキルは Phase 2 の親プロセスとして機能する。
自身では個別の評価を行わず、7 観点のサブスキルを並列起動して結果を集約する。

このスキルおよび配下のサブスキルは **コードを書き換えない**。

## 入力契約

以下の入力を受け取る。

- レビュー対象ファイル一覧
- (任意) Phase 1 で得たユーザーの意図・背景 (Markdown)

単独起動された場合、レビュー対象ファイル一覧を Step 0 の手順で取得する。

## Step 0: レビュー対象ファイルの特定 (単独起動時のみ)

親スキル code_review から呼ばれた場合は、レビュー対象ファイル一覧が
入力として渡されるので、この Step はスキップする。

単独起動の場合は以下の順で取得する。

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null)
```

`DEFAULT_BRANCH` が空 (`origin/HEAD` 未設定) の場合は `git remote set-head origin --auto` を
試し、再度 `git symbolic-ref` を実行する。それでも空なら AskUserQuestion で
比較対象ブランチを尋ねる (`origin/main` / `origin/master` / Other を選択肢に提示)。

`DEFAULT_BRANCH` が取得できたら差分を取得する。

```bash
git diff --name-only --diff-filter=ACMR ${DEFAULT_BRANCH}...HEAD
```

差分が空なら staged を確認する。

```bash
git diff --name-only --diff-filter=ACMR --cached
```

両方とも空なら AskUserQuestion で対象ファイルを尋ねる。

## Step 1: サブスキルの並列起動

以下の 7 サブスキルを Task ツールで **並列に** 起動する。
1 つのメッセージで 7 つの Task ツール呼び出しを発行すること。

| サブスキル | 観点 |
|-----------|------|
| code_inspect__complexity | 認知的複雑度 + 計算量 |
| code_inspect__readability | 命名・コメント・制御フロー・変数スコープ・タイポ |
| code_inspect__consistency | 既存コード・ドメイン用語との一貫性 |
| code_inspect__design | 依存性逆転・モジュール境界・拡張性 |
| code_inspect__security | 機密情報・injection・unsafe deserialize・access control |
| code_inspect__testability | テスト容易性・副作用・純粋性 |
| code_inspect__error_handling | エラー伝播・握り潰し |

### Task 起動パラメータ

各 Task 呼び出しでは以下を指定する。

- `subagent_type`: `general-purpose` (汎用エージェントを使用。各 leaf SKILL.md
  の `tools` 制約は subagent 側でロードされるため、ここでは general を選択)
- `description`: `inspect:<観点>` のように観点名を含める
- `prompt`: 下記テンプレート

### 評価範囲

各 leaf は **対象ファイル全体を Read して評価する** (差分行のみではなく)。
そのため差分外の既存コードへの指摘も含まれうる。集約時はその前提で読む。
これは file 単位の認知的複雑度・命名・設計判断を見るために必要な選択。

### プロンプトテンプレート

```
.claude/skills/code_inspect__<観点>/SKILL.md の指示に従って評価を実施してください。

## 入力
- レビュー対象ファイル一覧:
  <ファイル一覧>
- Phase 1 で得たユーザーの意図・背景:
  <Phase 1 の Markdown、なければ「なし」と記載>

## 出力契約
.claude/skills/code_inspect/template/inspect_output.md を Read し、
そこに定義された Markdown 形式で結果を返してください。

## 禁止事項
- Edit / Write を使わない (Read + Bash のみ)
- ユーザーに直接話しかけない (出力は呼び出し元に返すだけ)
```

## Step 2: 集約レポートの作成

全サブスキルの結果が揃ったら、各 leaf 出力から重要度ラベルをカウントする。
カウントは以下のパターンで行う。

- `[must]` で始まる箇条書き行 → must 件数に加算
- `[should]` で始まる箇条書き行 → should 件数に加算
- `[nit]` で始まる箇条書き行 → nit 件数に加算

各 leaf の `### 指摘` セクション内のみを対象とし、所見セクションや
出力例として埋め込まれた例文は対象外とする (Markdown コードブロック内も除外)。

集計後、以下の形式で集約レポートを返す。

```markdown
# 技術レビュー結果

レビュー対象: <ファイル数> ファイル

## サマリ
- must: N 件
- should: M 件
- nit: K 件

## 観点別

### complexity
（code_inspect__complexity の出力をそのまま埋め込む）

### readability
（code_inspect__readability の出力をそのまま埋め込む）

### consistency
（code_inspect__consistency の出力をそのまま埋め込む）

### design
（code_inspect__design の出力をそのまま埋め込む）

### security
（code_inspect__security の出力をそのまま埋め込む）

### testability
（code_inspect__testability の出力をそのまま埋め込む）

### error_handling
（code_inspect__error_handling の出力をそのまま埋め込む）
```

## 禁止事項

- Edit / Write を使わない (Read + Bash + Task のみ)
- サブスキルを順次起動しない (必ず並列で起動する)
- 観点の合否ラベルを付けない (重要度 must/should/nit に集約)
