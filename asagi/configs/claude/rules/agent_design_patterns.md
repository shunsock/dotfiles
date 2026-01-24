# Agent Design Patterns

このドキュメントは、エージェント設計の共通パターン、処理フロー、並列処理、全体的な位置づけに関するルールを定義します。

## 目次

1. [処理フローの標準構造](#1-処理フローの標準構造)
2. [役割と責務の定義](#2-役割と責務の定義)
3. [Accept vs Deny パターン](#3-accept-vs-deny-パターン)
4. [並列処理の活用](#4-並列処理の活用)
5. [小規模ソフトウェアエンジニアリング受託企業モデル](#5-小規模ソフトウェアエンジニアリング受託企業モデル)

---

## 1. 処理フローの標準構造

### Phase構造テンプレート

すべてのエージェントは、以下の5フェーズ構造に従うことが推奨されます：

```
Phase 1: 初期化・認証確認
  ↓
Phase 2: 分析・調査
  ↓
Phase 3: 品質ゲート・ユーザー確認
  ↓
Phase 4: 成果物作成
  ↓
Phase 5: 出力・更新
```

### ✅ Good Example

```markdown
## 処理フロー

### Phase 1: 初期化

1. GitHub CLI認証確認
   ```bash
   gh auth status
   ```
2. Epic Issue取得
   ```bash
   gh issue view ${ISSUE_NUMBER}
   ```

### Phase 2: 分析

1. Issue内容の構造化
2. 必須セクションの存在チェック
3. 不足情報の特定

### Phase 3: ユーザー確認ポイント [1]

不足している情報をユーザーに質問：
- 背景・動機が不明確な場合
- ゴールが曖昧な場合
- Acceptance Criteriaが欠落している場合

### Phase 4: 強化案作成

1. ユーザーの回答を統合
2. 強化されたEpic Issueドラフト作成

### Phase 5: ユーザー確認ポイント [2] → Issue更新

1. ドラフトをユーザーにレビュー依頼
2. 承認後に `gh issue edit` で更新
```

### ❌ Bad Example

```markdown
## 処理フロー

1. Issueを取得して分析
2. 修正して更新

（フェーズが不明確、ユーザー確認ポイントがない）
```

### ユーザー確認ポイント [N] の配置

各フェーズで**ユーザー確認ポイント [1], [2], ...**を挿入します。これにより、ユーザーの意図を正確に反映し、品質を担保します。

#### 配置例

| フェーズ | 確認ポイント | 確認内容 |
|---------|------------|---------|
| Phase 2終了時 | [1] | 分析結果の確認、不足情報の質問 |
| Phase 4終了時 | [2] | ドラフトのレビュー、承認依頼 |
| Phase 5実行前 | [3] | 最終確認、Issue更新の承認 |

### チェックリスト

- [ ] Phase 1で初期化・認証確認を実施
- [ ] Phase 2で分析・調査を実施
- [ ] Phase 3でユーザー確認ポイントを配置
- [ ] Phase 4で成果物を作成
- [ ] Phase 5で出力・更新を実施
- [ ] 各Phaseの目的が明確に記載されている
- [ ] ユーザー確認ポイントが少なくとも1つ以上ある

### 参照

- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 1-5の完全な例
- [`agents/sub_issue_creator.md`](../agents/sub_issue_creator.md) - ユーザー確認ポイントの活用

---

## 2. 役割と責務の定義

### エージェント定義の構造

すべてのエージェントは、以下の構造で定義されます：

```markdown
## 役割

5-10行の簡潔な説明。エージェントが何をするのか、なぜ必要なのかを明確に記述。

## 責務

- 責務1: 具体的な責務の説明
- 責務2: 具体的な責務の説明
- 責務3: 具体的な責務の説明

## 成果物

- 出力形式1: YAML / Markdown / GitHub Issue
- 出力形式2: 内容の説明
```

### ✅ Good Example

```markdown
## 役割

Epic Issueを分析し、不足情報を補完して強化するエージェント。
ユーザーが作成したEpic Issueは、背景・現状・ゴール・実装方針・Acceptance Criteriaが不足していることが多い。
このエージェントは、必須セクションの存在チェックを行い、不足項目についてユーザーに質問し、
強化後のドラフトを作成してユーザーレビューを経た後、Issue更新を行う。

## 責務

- Epic Issueの構造分析と必須セクション（背景・現状・ゴール・実装方針・AC）の存在チェック
- 不足情報についてユーザーに質問し、回答を収集
- 強化されたEpic Issueドラフトの作成とユーザーレビュー
- 承認後の `gh issue edit` によるIssue更新

## 成果物

- 強化版Epic Issue (GitHub Issue): 必須セクション完備、sub-issue-creatorで分割可能な状態
```

### ❌ Bad Example

```markdown
## 役割

Issueを強化する。

## 責務

- Issueの分析
- 更新

（役割が不明確、責務が曖昧）
```

### チェックリスト

- [ ] 役割が5-10行で明確に記述されている
- [ ] 責務が3-4個にまとめられている
- [ ] 各責務が具体的で検証可能
- [ ] 成果物の形式と内容が明確

### YAMLテンプレート（役割と責務）

```yaml
agent_definition:
  role: |
    5-10行の簡潔な説明。
    エージェントが何をするのか、なぜ必要なのかを明確に記述。
  responsibilities:
    - 責務1: 具体的な責務の説明
    - 責務2: 具体的な責務の説明
    - 責務3: 具体的な責務の説明
  deliverables:
    - format: YAML / Markdown / GitHub Issue
      content: 成果物の内容説明
```

### 参照

- [`agents/business_analyst.md`](../agents/business_analyst.md) - 役割と責務の明確な定義例
- [`agents/solution_architect.md`](../agents/solution_architect.md) - 複雑な責務の整理例

---

## 3. Accept vs Deny パターン

### 基本原則

エージェントとスキルは、「推奨する行動（Accept）」と「禁止する行動（Deny）」を明確に示します。

### ✅ Accept（すべきこと）

- **既存パターンを踏襲**: 既存の設計パターン、コーディング規約に従う
- **プロジェクト規約に準拠**: .eslintrc, .prettierrc, コミット規約など
- **一貫性の維持**: 命名規則、ディレクトリ構造、ファイル構成の統一

```yaml
# ✅ Good: 既存パターン踏襲
既存パターンとの整合性:
  - Accept: 既存の設計パターンを踏襲
  - Accept: プロジェクトのコーディング規約に準拠
  - Accept: 既存のディレクトリ構造に従う
```

### ❌ Deny（すべきでないこと）

- **独自パターン**: 既存パターンと異なる独自の実装方式
- **規約無視**: プロジェクト規約を無視した実装
- **一貫性の欠如**: 命名規則やスタイルの不統一

```yaml
# ❌ Bad: 既存パターン無視
既存パターンとの整合性:
  - Deny: 既存パターンと異なる独自の実装方式
  - Deny: プロジェクト規約を無視した実装
  - Deny: 命名規則やスタイルの不統一
```

### 具体例

#### ✅ Good Example

```python
# 既存のコーディング規約に従う
# プロジェクトではPEP 8準拠、型ヒント必須

def calculate_total_price(items: List[Item]) -> Decimal:
    """商品リストの合計金額を計算する

    Args:
        items: 商品のリスト

    Returns:
        合計金額（Decimal型）
    """
    return sum(item.price * item.quantity for item in items)
```

#### ❌ Bad Example

```python
# 既存パターンを無視
# プロジェクトではPEP 8準拠なのに、異なるスタイル

def CalculateTotalPrice(items):  # 型ヒントなし、キャメルケース
    total = 0
    for item in items:
        total += item.price * item.quantity
    return total
```

### チェックリスト

- [ ] 既存の設計パターンを調査済み
- [ ] プロジェクトのコーディング規約を確認済み
- [ ] 既存のディレクトリ構造・命名規則に従っている
- [ ] 独自パターンを導入していない

### 参照

- [`agents/code_reviewer.md`](../agents/code_reviewer.md) - Accept/Denyパターンの評価
- [`agents/implementation_strategist.md`](../agents/implementation_strategist.md) - 既存パターン踏襲の例

---

## 4. 並列処理の活用

### 並列実行可能フェーズ

以下のフェーズでは、複数のエージェントを並列起動して効率化を図ります。

#### Phase 1 Phase 2.5（epic-issue-enhancer内）

```
epic-issue-enhancer Phase 2.5: サブエージェント起動
  ├─ business-analyst（並列）
  ├─ infrastructure-researcher（並列）
  └─ code-researcher x4（並列）
      ├─ pattern研究
      ├─ impact研究
      ├─ technology研究
      └─ testing研究
```

**起動方法**: 単一のメッセージで複数のTask tool呼び出し

```python
# 並列起動の例（疑似コード）
await asyncio.gather(
    launch_agent("business-analyst", epic_issue),
    launch_agent("infrastructure-researcher", epic_issue),
    launch_agent("code-researcher", epic_issue, perspective="pattern"),
    launch_agent("code-researcher", epic_issue, perspective="impact"),
    launch_agent("code-researcher", epic_issue, perspective="technology"),
    launch_agent("code-researcher", epic_issue, perspective="testing"),
)
```

#### Phase 4（impl-issue-enhancer内）

```
impl-issue-enhancer Phase 4: サブエージェント起動
  ├─ code-researcher x4（並列）
  ├─ implementation-strategist（順次）
  └─ test-designer（順次、implementation-strategistの出力を参照）
```

**注意**: implementation-strategistとtest-designerは**順次実行**（test-designerがimplementation-strategistの出力を参照するため）

#### Phase 7（リリース準備）

```
リリース準備
  ├─ pull-request-writer（並列）
  └─ document-writer（並列）
```

### ✅ Good Example（並列実行）

```markdown
### Phase 2.5: サブエージェント起動

以下の3つのエージェントを**並列起動**して効率化：

1. business-analyst - ビジネス要件分析
2. infrastructure-researcher - インフラ調査
3. code-researcher x4 - コードベース調査（4観点並列）

**起動方法**: 単一のメッセージで6個のTask tool呼び出し
```

### ❌ Bad Example（順次実行）

```markdown
### Phase 2.5: サブエージェント起動

以下のエージェントを順次起動：

1. business-analyst起動 → 完了待ち
2. infrastructure-researcher起動 → 完了待ち
3. code-researcher起動（pattern） → 完了待ち
4. code-researcher起動（impact） → 完了待ち
...

（依存関係がないのに順次実行は非効率）
```

### 並列実行時の依存関係チェックリスト

- [ ] エージェント間に依存関係がない
- [ ] 各エージェントの入力が独立している
- [ ] 並列実行で実行時間が短縮される
- [ ] 順次実行が必要な場合は明示的に記載

### 参照

- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 2.5での並列起動
- [`agents/code_researcher.md`](../agents/code_researcher.md) - 4観点並列実行
- [`agents/impl_issue_enhancer.md`](../agents/impl_issue_enhancer.md) - Phase 4での並列・順次制御

---

## 5. 小規模ソフトウェアエンジニアリング受託企業モデル

### チーム構成とエージェントの対応関係

Claude Codeのカスタムエージェント群は、**小規模なソフトウェアエンジニアリング受託企業**の開発体制を模した設計になっています。
各エージェントは特定の専門性を持つチームメンバーとして機能し、要件定義からリリースまでの一貫した開発フローを実現します。

| 役割カテゴリ | エージェント | 業務内容 | 受託企業での位置づけ |
|------------|------------|---------|-------------------|
| **要件定義チーム** | epic-issue-enhancer | 顧客要件の整理・明確化 | プロジェクトマネージャー (PM) |
| | business-analyst | ビジネス価値分析・ROI試算 | ビジネスアナリスト (BA) |
| | infrastructure-researcher | インフラ現状調査 | インフラエンジニア (調査) |
| | code-researcher x4 | 既存システム調査 | テクニカルリサーチャー |
| **基本設計チーム** | solution-architect | アーキテクチャ設計・技術選定 | ソリューションアーキテクト |
| **要件分割チーム** | sub-issue-creator | 実装単位への要件分割 | プロジェクトマネージャー (PM) |
| **詳細設計チーム** | impl-issue-enhancer | 実装Issue詳細化 | リードエンジニア |
| | implementation-strategist | コードレベル設計 | シニアエンジニア |
| | test-designer | テスト設計 | QAエンジニア |
| **実装チーム** | developer | TDD実装、code-reviewer連携 | 開発者 (Developer) |
| **品質保証チーム** | code-reviewer | コード品質レビュー | コードレビュアー |
| **リリース準備チーム** | pull-request-writer | PR作成・レビュー支援 | リードエンジニア |
| | document-writer | 技術文書作成 | テクニカルライター |

### 開発プロセスの特徴

1. **段階的な詳細化**: Epic Issueから始まり、段階的に詳細度を上げていく
2. **品質ゲートの設置**: 各フェーズ終了時にユーザー確認を挟み、品質を担保
3. **並列処理の活用**: 要件定義フェーズでは複数エージェントを並列起動して効率化
4. **トレーサビリティの確保**: 各成果物間の関係を明示し、変更の影響範囲を把握可能

### 受託企業としての価値提供

- **完全性**: 要件定義からリリースまでの全工程をカバー
- **品質**: 各フェーズでの品質ゲートによる高品質な成果物
- **透明性**: ユーザーレビューポイントでの進捗確認と意思決定
- **柔軟性**: オプショナルフェーズによる状況に応じた最適化

### 開発工程の全体像

```
Phase 1: 要件定義 (Requirements Definition)
    ↓
Phase 2: 基本設計 (Basic Design / High-Level Design)
    ↓
Phase 3: 要件分割 (Requirements Breakdown)
    ↓
Phase 4: 詳細設計 (Detailed Design / Low-Level Design)
    ↓
Phase 5: 実装 (Implementation)
    ↓
Phase 6: コードレビュー (Code Review / Quality Assurance)
    ↓
Phase 7: リリース準備 (Release Preparation)
```

### チェックリスト

- [ ] エージェントの役割が受託企業のチーム構成と対応している
- [ ] 各フェーズでの品質ゲートが設置されている
- [ ] ユーザー確認ポイントが適切に配置されている
- [ ] 成果物間のトレーサビリティが確保されている

### 参照

- [`configs/claude/CLAUDE.md`](../CLAUDE.md) - エージェント群の位置づけと全体フロー
- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - 要件定義チームの代表例
- [`agents/developer.md`](../agents/developer.md) - 実装チームの代表例

---

## まとめ

Agent Design Patternsでは、以下の5つの主要な領域をカバーしています：

1. **処理フローの標準構造**: 5フェーズ構造とユーザー確認ポイント
2. **役割と責務の定義**: 明確なエージェント定義の構造
3. **Accept vs Deny パターン**: 既存パターン踏襲の重要性
4. **並列処理の活用**: 効率化のための並列実行戦略
5. **小規模ソフトウェアエンジニアリング受託企業モデル**: エージェント群の全体的な位置づけ

これらのパターンに従うことで、一貫性のある高品質なエージェント設計が可能になります。
