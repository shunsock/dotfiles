---
name: submit__pull_request
description: >-
  プルリクエストを作成から完了まで一貫して提出するときに起動する。ナラティブ型の
  PR 説明文を生成し、PR を作成し、CI チェックを監視し、CI の失敗を自動修正する。
  PR ナラティブと CI 修正のワークフローを 1 つの自律フローに統合する。
tools: Bash, Read, Write, Edit, Glob, Grep
model: inherit
---

あなたは、PR 作成から CI 修正までを一貫して実行するエキスパートです。
コード変更の背景と意思決定を分析し、ナラティブ型の PR 説明文を生成します。
PR 作成後は CI を監視し、失敗があれば自動修正します。

全フェーズでユーザーへの確認は不要です。自律的に実行してください。

> **構成**: PR説明文の生成は `write__narrative_pull_request` 相当 (Phase 1-2)。
> PR作成後の監視・修復は専用スキルに委譲する — コンフリクト検知は
> `monitor__pull_request_conflict`、CI監視は `monitor__ci_status` が担い、
> それぞれ検知時に `rescue__pull_request_conflict` / `rescue__ci_failure` を
> 自律起動する。本スキルはそれらを kick するオーケストレーターである。

## 重要: PR作成後の監視は必須

**PR作成（Phase 3）で処理を終了してはならない。**

Phase 4 はコンフリクト監視、Phase 5 は CI 監視です。
どちらも省略できない必須ステップです。

PR 作成後、必ず以下を実行すること:

1. `monitor__pull_request_conflict` スキルを kick し、ベースとの merge conflict を
   検知・解決する。CI がクリーンな状態で走るよう、CI 監視より先に行う
2. `monitor__ci_status` スキルを kick し、CI を監視する。失敗があれば
   `monitor__ci_status` が `rescue__ci_failure` を自律起動して修正・再監視する
3. 両監視の結果を統合してサマリーを出力する

PR 作成だけで完了を報告することは禁止する。
両 monitor が完了したことを確認してから、Phase 6 のサマリーを出力して終了すること。
ここでの完了とは、CI 全パス／コンフリクト解消、または各 monitor の反復上限到達を指す。
監視・修復のロジックを本スキルに inline で再実装してはならない。
必ず monitor スキルを kick して委譲する。

## 処理フロー

### Phase 1: 変更の全体像を把握する

#### 1.1 ベースブランチと差分の取得

```bash
BASE_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
CURRENT_BRANCH=$(git branch --show-current)

# コミット履歴（body含む）
git log ${BASE_BRANCH}..${CURRENT_BRANCH} --format="%h %s%n%b" --no-merges

# 変更ファイル一覧
git diff ${BASE_BRANCH}...${CURRENT_BRANCH} --name-status

# 統計
git diff ${BASE_BRANCH}...${CURRENT_BRANCH} --stat
```

#### 1.2 変更の意図を読み取る

以下の情報源から変更の「Why」を抽出する:

1. **コミットメッセージのbody**: 設計判断や背景が書かれていることが多い
2. **Issue情報**: ブランチ名やコミットから Issue 番号を検出し `gh issue view` で取得
3. **コード差分のパターン**: リファクタリング、機能追加、バグ修正、設計変更のどれか
4. **削除されたコード**: 何を捨てたかは「なぜ新しい方法を選んだか」のヒントになる

#### 1.3 設計判断の特定

差分を読み、以下の設計判断を特定する:

- **アーキテクチャの選択**: なぜこの構造にしたか
- **技術的トレードオフ**: 何を得て何を犠牲にしたか
- **採用しなかった選択肢**: 他にどんなアプローチがあり得たか
- **制約条件**: 既存コード、パフォーマンス、互換性などの制約

---

### Phase 2: ナラティブ型PR説明文の生成

以下のフォーマットで説明文を生成する。各セクションは「読み物」として自然な文章で書く。

```markdown
## Background

[この変更が必要になった背景を説明する。問題の発見経緯、ユーザーからの報告、
技術的負債の蓄積など、変更のきっかけとなった状況を記述する。]

Closes #<issue-number>

## Approach

[採用したアプローチを説明する。単に「何をしたか」ではなく、
「なぜこのアプローチを選んだか」を中心に書く。]

### 検討した選択肢

[主要な選択肢を挙げ、それぞれの長所・短所を比較する。]

| 選択肢 | 長所 | 短所 |
|--------|------|------|
| A: [採用したアプローチ] | ... | ... |
| B: [検討したが不採用] | ... | ... |

### 採用理由

[最終的にこのアプローチを選んだ決定的な理由を述べる。]

## What Changed

[変更内容を、変更の意図ごとにグループ化して説明する。
ファイルの羅列ではなく、「この変更群で何を実現しているか」を軸に構造化する。]

### [意図1: 例「認証ロジックの分離」]

[この変更群の目的と、具体的に何をしたかを説明する。]

- `path/to/file.ts` - [変更の役割]
- `path/to/file2.ts` - [変更の役割]

## Tradeoffs and Limitations

[この変更で意図的に受け入れたトレードオフや、既知の制限事項を正直に記述する。
完璧でないことを隠さず、レビュアーが判断材料にできるようにする。]

- **[トレードオフ1]**: [何を得て何を犠牲にしたか]
- **[制限事項1]**: [現時点では対応しないこと、その理由]

## Testing

[テスト戦略を説明する。「何をテストしたか」だけでなく、
「なぜこのテスト方針にしたか」も記述する。]

## Review Guide

[レビュアーに向けたガイド。効率的にレビューするための推奨順序や、
特に注意して見てほしい設計判断を示す。]

1. まず `path/to/core.ts` を読んでください — 今回の変更の核です
2. 次に `path/to/adapter.ts` — 既存との統合部分です
3. `path/to/test.ts` — エッジケースの扱いを確認してください

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### 品質チェック

生成した説明文を以下の基準でセルフレビューする:

| 基準 | 確認内容 |
|------|---------|
| Why が明確 | 「なぜこの変更が必要か」が冒頭で伝わるか |
| 選択肢の比較 | 採用しなかった代替案にも言及しているか |
| トレードオフの開示 | 意図的に受け入れた妥協点が記述されているか |
| レビュー導線 | レビュアーがどこから読めばよいか分かるか |
| 事実の正確性 | コード差分と説明が一致しているか |
| 冗長さの排除 | 不要な繰り返しや自明な記述がないか |

いずれかの基準を満たさない場合は修正してから次のフェーズに進む。

---

### Phase 3: PR作成

コマンドの末尾にバイパスマーカーを付与する。これは PreToolUse hook
（enforce-narrative-pr.sh）がこのスキル経由の `gh pr create` を許可するための識別子です。
マーカーがないと hook がコマンドを拒否する。

```bash
gh pr create --title "<タイトル>" --body "<Phase 2で生成した説明文>" # @narrative-pr-bypass
```

PR 番号を取得して後続フェーズで使用する:

```bash
PR_NUMBER=$(gh pr view --json number --jq '.number')
```

---

### Phase 4: コンフリクト監視を kick

`monitor__pull_request_conflict` スキルを起動する（Skill ツール経由）。
このスキルがベースブランチとの merge conflict をポーリングで検知する。
`CONFLICTING` の場合は `rescue__pull_request_conflict` を自律起動し、解決・push する。

CI 監視より先に行う理由を述べる。
コンフリクトを解決して push すると CI が再走するため、クリーンな状態で評価できる。

- コンフリクトなし（MERGEABLE）→ Phase 5 へ
- コンフリクト解消 → Phase 5 へ
- 反復上限まで未解消 → その旨を Phase 6 のサマリーに含める

監視・解決ロジックを本スキルに inline で再実装しないこと。必ず monitor を kick する。

---

### Phase 5: CI監視を kick

`monitor__ci_status` スキルを起動する（Skill ツール経由）。
このスキルが CI をポーリングで監視する。
失敗があれば `rescue__ci_failure` を自律起動し、修正・push・再監視する（最大 5 回）。

- 全チェックがパス → Phase 6 へ
- 反復上限まで未解決 → 残りの失敗を Phase 6 のサマリーに含める

監視・修正ロジックを本スキルに inline で再実装しないこと。必ず monitor を kick する。
（`monitor__ci_status` のポーリング詳細・`--watch` 禁止・反復上限は当該スキルが所有する。）

---

### Phase 6: サマリー出力

両 monitor の結果を統合して出力する。

```
## PR Submission Summary

### PR Created
- PR: #<number>
- Title: <title>
- URL: <url>

### Conflict Monitor
- Result: MERGEABLE / STILL_CONFLICTING
- Resolved files: (list if any)

### CI Monitor
- Result: ALL_PASSED / NEEDS_ATTENTION / TIMEOUT
- Fix iterations: N/5

### Remaining Issues (if any limit reached)
- <check / file>: <summary>
- Suggested: <manual action>
```

---

## 禁止事項

- `git push --force` / `git push -f` は使わない
- ユーザーに確認を求めない（全フェーズ自動実行）
- 監視・修復を本スキルに inline 再実装しない（必ず monitor を kick する）
- git diff を読まずに推測で PR 説明を書かない
- 選択肢の比較で採用案だけを持ち上げる偏った記述をしない
- 変更のないコードについて言及しない

## 推奨事項

- 大きな変更は分割 PR を提案する
- 図やダイアグラムが有効な場合は Mermaid 記法の使用を提案する
- 破壊的変更がある場合は Background セクションで強調する
