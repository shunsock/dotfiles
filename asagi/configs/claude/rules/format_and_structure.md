# Format and Structure Rules

このドキュメントは、YAML形式、命名規則、成果物形式、エージェント間入出力仕様に関するルールを定義します。

## 目次

1. [YAML Format Requirements](#1-yaml-format-requirements)
2. [Naming Conventions](#2-naming-conventions)
3. [成果物のファイル命名規則](#3-成果物のファイル命名規則)
4. [エージェント間入出力仕様](#4-エージェント間入出力仕様)

---

## 1. YAML Format Requirements

### 必須項目

すべてのエージェントとスキルは、以下の必須項目をYAML frontmatterに含める必要があります：

```yaml
---
name: エージェント名またはスキル名
description: 簡潔な説明（1-2行）
tools: 利用可能なツールのリスト（カンマ区切り）
model: inherit または特定のモデルID
---
```

### ✅ Good Example

```yaml
---
name: epic-issue-enhancer
description: Epic Issueを分析し、不足情報を補完して強化するエージェント
tools: Bash, Read, Glob, Grep, WebFetch
model: inherit
---

Epic Issue Enhancerは、ユーザーが作成したEpic Issueを分析し...
```

### ❌ Bad Example

```yaml
---
name: my-agent
# descriptionが欠落
tools: Bash Read Write  # カンマ区切りではない
# modelが欠落
---
```

### ネストの深さ規則

YAML出力では、ネストの深さを**3-4階層まで**に制限します。これにより可読性を保ちます。

```yaml
# ✅ Good: 3階層
phase_1:
  findings:
    - 発見事項1
    - 発見事項2
  recommendations:
    - 推奨事項1

# ❌ Bad: 6階層（深すぎる）
project:
  modules:
    frontend:
      components:
        forms:
          validation:
            rules: ...  # 深すぎる
```

### チェックリスト

- [ ] `name` フィールドが存在する
- [ ] `description` フィールドが存在し、1-2行で説明されている
- [ ] `tools` がカンマ区切りで記載されている
- [ ] `model` フィールドが存在する（`inherit` または特定のモデルID）
- [ ] YAMLネストが4階層以下

### YAMLテンプレート（コピー可能）

```yaml
---
name: your-agent-name
description: Brief description of your agent
tools: Bash, Read, Write, Glob, Grep
model: inherit
---

# Your Agent Name

## 役割

Your agent's role description here.

## 処理フロー

### Phase 1: 初期化
...
```

### 参照

- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - 完全なエージェント定義の例
- [`skills/write__sdd_issue/SKILL.md`](../skills/write__sdd_issue/SKILL.md) - スキル定義の例

---

## 2. Naming Conventions

### 変数・関数命名

#### ✅ Accept

- **意図が明確**: `getUserProfile()`, `calculateTotalPrice()`, `isAuthenticated`
- **ドメイン用語を使用**: `epicIssue`, `subIssue`, `acceptanceCriteria`
- **プロジェクト全体で統一**: キャメルケースまたはスネークケースのいずれかに統一

```python
# ✅ Good
def get_user_profile(user_id: int) -> UserProfile:
    """ユーザープロファイルを取得する"""
    return database.query(UserProfile).filter_by(id=user_id).first()

# ✅ Good
def calculate_total_price(items: List[Item]) -> Decimal:
    """商品リストの合計金額を計算する"""
    return sum(item.price * item.quantity for item in items)
```

#### ❌ Deny

- **略語多用**: `usr`, `tmp`, `data`, `calc`
- **一貫性なし**: キャメルケースとスネークケースの混在
- **誤解を招く**: `isValid` なのに副作用がある、`get` なのに状態を変更する

```python
# ❌ Bad
def usr_prof(id):  # 略語多用、型ヒントなし
    return db.get(id)

# ❌ Bad
def isValid(user):  # 副作用あり（データベース更新）
    user.last_checked = datetime.now()
    user.save()
    return True
```

### ファイル・ディレクトリ命名

**原則**: 既存のパターンに従う

新規作成時は、既存の命名規則を調査してから命名します：

```bash
# ディレクトリ構造を確認
ls -la configs/claude/

# 既存のエージェント命名を確認
ls configs/claude/agents/

# 既存のスキル命名を確認
ls configs/claude/skills/
```

#### チェックリスト

- [ ] 意図が明確な命名（`getUserProfile` vs `get`）
- [ ] ドメイン用語を使用
- [ ] プロジェクト全体で命名規則が統一されている
- [ ] 略語を多用していない
- [ ] 誤解を招く命名を避けている

### 参照

- [`agents/implementation_strategist.md`](../agents/implementation_strategist.md) - 命名規則の評価例

---

## 3. 成果物のファイル命名規則

### 標準命名パターン

エージェントの成果物は、以下の命名規則に従います：

| エージェント | 成果物ファイル名 | 形式 |
|------------|--------------|------|
| code-researcher | `${perspective}_research.yaml` | YAML |
| business-analyst | `business_analyst_output.yaml` | YAML |
| infrastructure-researcher | `infrastructure_researcher_output.yaml` | YAML |
| implementation-strategist | `implementation_strategy_*.yaml` | YAML |
| test-designer | `test_design_*.yaml` | YAML |
| code-reviewer | `code_review_result.yaml` | YAML |
| solution-architect | `solution_proposal_*.md` | Markdown |

### ✅ Good Example

```bash
# code-researcherの4観点
pattern_research_epic_123.yaml
impact_scope_epic_123.yaml
tech_stack_epic_123.yaml
test_structure_epic_123.yaml

# implementation-strategist
implementation_strategy_issue_456.yaml

# test-designer
test_design_issue_456.yaml
```

### ❌ Bad Example

```bash
# 一貫性なし
research.yaml
output.yaml
result.txt
```

### チェックリスト

- [ ] ファイル名にエージェント名または成果物の種類が含まれている
- [ ] 関連するIssue番号やEpic番号が含まれている（識別のため）
- [ ] 拡張子が適切（`.yaml` または `.md`）

### YAMLテンプレート（成果物）

```yaml
# ${perspective}_research.yaml
---
perspective: pattern  # pattern / impact / technology / testing
epic_number: 123
findings:
  - 発見事項1: 詳細説明
  - 発見事項2: 詳細説明
recommendations:
  - 推奨事項1
  - 推奨事項2
---
```

### 参照

- [`agents/code_researcher.md`](../agents/code_researcher.md) - 4観点の成果物命名
- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 3での成果物収集

---

## 4. エージェント間入出力仕様

### Phase間の成果物の流れ

各フェーズの成果物は、次のフェーズで活用されます：

#### Phase 1 → Phase 2（要件定義 → 基本設計）

```
epic-issue-enhancer (Phase 5完了)
  ├─ 強化版Epic Issue (GitHub Issue)
  └─ サブエージェント出力
      ├─ business_analyst_output.yaml
      ├─ infrastructure_researcher_output.yaml
      ├─ pattern_research_*.yaml
      ├─ impact_scope_*.yaml
      ├─ tech_stack_*.yaml
      └─ test_structure_*.yaml
          ↓
solution-architect (Phase 3.5で起動)
  └─ ソリューション提案書 (Markdown) → Epic Issue Phase 4に統合
```

#### Phase 2 → Phase 3（基本設計 → 要件分割）

```
solution-architect (または epic-issue-enhancer)
  └─ 強化版Epic Issue
      ↓
sub-issue-creator
  └─ Sub Issues (GitHub Issues) × N個
```

#### Phase 3 → Phase 4（要件分割 → 詳細設計）

```
sub-issue-creator
  └─ Sub Issue
      ↓
impl-issue-enhancer (オプション)
  ├─ code-researcher x4起動（必要に応じて並列）
  │   ├─ pattern_research_*.yaml
  │   ├─ impact_scope_*.yaml
  │   ├─ tech_stack_*.yaml
  │   └─ test_structure_*.yaml
  ├─ implementation-strategist起動
  │   └─ implementation_strategy_*.yaml
  └─ test-designer起動
      └─ test_design_*.yaml
          ↓
  強化版Sub Issue (GitHub Issue)
```

#### Phase 4 → Phase 5（詳細設計 → 実装）

```
impl-issue-enhancer (または Sub Issue)
  ├─ 強化版Sub Issue (GitHub Issue)
  ├─ code_researcher_*.yaml (オプション)
  ├─ implementation_strategy_*.yaml
  └─ test_design_*.yaml
      ↓
developer
  ├─ Phase 1-4: TDD サイクル（Red-Green-Refactor）
  ├─ Phase 5: code-reviewer起動
  ├─ Phase 6: 指摘対応（修正ループ）
  └─ Phase 7: git commit作成
```

#### Phase 5 → Phase 6（実装 → コードレビュー）

```
developer (Phase 5)
  └─ WIP commit + code-reviewer起動
      ↓
code-reviewer
  └─ code_review_result.yaml
      ↓
developer (Phase 6)
  └─ Mustfix対応 → 再レビュー（最大3回）
      ↓
developer (Phase 7)
  └─ git commit (実装完了)
```

#### Phase 6 → Phase 7（コードレビュー → リリース準備）

```
code-reviewer
  └─ code_review_result.yaml
      ↓
pull-request-writer
  └─ GitHub Pull Request
```

### 入出力のYAMLテンプレート

```yaml
# implementation_strategy_*.yaml
---
issue_number: 456
epic_number: 123
technical_approach:
  architecture: 選定されたアーキテクチャ
  libraries:
    - ライブラリ1
    - ライブラリ2
file_structure:
  - path: src/components/NewComponent.tsx
    purpose: コンポーネントの目的
implementation_order:
  - phase: Phase 1
    tasks:
      - タスク1
      - タスク2
---
```

### チェックリスト

- [ ] 成果物が標準命名規則に従っている
- [ ] 次フェーズで必要な情報が全て含まれている
- [ ] YAML形式が正しい（構文エラーなし）
- [ ] Issue番号/Epic番号が含まれている

### 参照

- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 2.5でのサブエージェント起動
- [`agents/impl_issue_enhancer.md`](../agents/impl_issue_enhancer.md) - Phase間の統合
- [`configs/claude/CLAUDE.md`](../CLAUDE.md) - 全体フローの図解

---

## まとめ

Format and Structure Rulesでは、以下の4つの主要な領域をカバーしています：

1. **YAML形式**: frontmatter構造、必須項目、ネスト規則
2. **命名規則**: 変数・関数・ファイルの命名ガイドライン
3. **成果物命名**: エージェントごとの標準ファイル名パターン
4. **入出力仕様**: Phase間の成果物の受け渡しフロー

これらのルールに従うことで、プロジェクト全体の一貫性と可読性が向上します。
