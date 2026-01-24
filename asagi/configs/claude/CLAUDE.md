# Claude Code Configuration

このファイルは、asagi プロジェクトで Claude Code が作業する際の動作指示書です。

## 構成

`configs/claude/` ディレクトリには以下の設定ファイルが含まれています：

- **skills/** - カスタムスキル定義
- **agents/** - カスタムサブエージェント定義
- **settings.json** - Claude Code の権限設定と環境変数
- **CLAUDE.md** (このファイル) - 各設定の参照と使用ガイドライン

詳細な技術情報やアーキテクチャについては、`../../CLAUDE.md` を参照してください。

## Custom Skills

以下のカスタムスキルが定義されています：

- **SDD Issue Maker** - スペック駆動開発の Issue 作成 (`./skills/write__sdd_issue/SKILL.md`)
  - Issue 作成時はこのガイドラインに厳格に従ってください
- **Version Management System** - Git/GitHub 操作 (`./skills/manage__git_github/SKILL.md`)
  - リポジトリ操作、コミット、プルリクエスト、Issue管理などのタスク
- **Nix Command** - Nix パッケージ管理 (`./skills/manage__nix_system/SKILL.md`)
  - パッケージ管理、システム設定、開発環境構築
- **Nix Run** - 一時的なコマンド実行 (`./skills/dispatch__nix_run_pkgs/SKILL.md`)
  - ホストOSに存在しないコマンドを `nix run` で一時的に実行
  - nixpkgsから直接パッケージを取得してシステムを汚さずに利用
- **Go-Task** - Taskfile.yml タスク実行 (`./skills/execute__go_task/SKILL.md`)
  - Taskfile.ymlに定義されたタスクの実行と管理
- **AWS Permission Request** - AWS IAM権限申請メッセージ生成 (`./skills/request__aws_iam_permission/SKILL.md`)
  - エラーログとGit差分を元に権限申請メッセージを自動生成
- **Gemini Web Search** - Gemini CLI を使用した Web 検索 (`./skills/search__web_by_gemini/SKILL.md`)
  - 組み込みweb_searchの代わりにGemini CLIを使用した高度な検索
- **Nix Packages Info** - HomeManager管理パッケージ情報取得 (`./skills/search__nix_packages/SKILL.md`)
  - GitHubリポジトリからhome.nixを取得してパッケージ一覧を表示
- **Dockerfile Best Practices** - Dockerfileの最適化とベストプラクティス (`./skills/write__dockerfile/SKILL.md`)
  - イメージサイズ削減、セキュリティ強化、ビルド速度向上
  - マルチステージビルド、distroless、非root実行
  - Docker Scout、Hadolintによる品質保証

## Custom Agents

以下のカスタムサブエージェントが定義されています。
エージェントはYAML frontmatter付きのMarkdown形式で、Claude Code公式のサブエージェント仕様に準拠しています。

### Epic Issue Enhancer (`./agents/epic_issue_enhancer.md`)

ユーザーが作成したEpic Issueを分析し、不足情報を補完して強化するエージェント。

| 項目 | 内容 |
|------|------|
| name | `epic-issue-enhancer` |
| tools | Bash, Read, Glob, Grep, WebFetch |
| model | inherit |

**処理フロー**:
1. GitHub CLI認証確認 → Epic Issue取得
2. 必須セクション（背景・現状・ゴール・AC）の存在チェック
3. 不足項目についてユーザーに質問
4. 強化後のドラフト作成 → ユーザーレビュー
5. 承認後に `gh issue edit` で更新

### Sub Issue Creator (`./agents/sub_issue_creator.md`)

Epic Issueから実装可能な粒度のSub Issueを作成するエージェント。

| 項目 | 内容 |
|------|------|
| name | `sub-issue-creator` |
| tools | Bash, Read, Glob, Grep, WebSearch |
| model | inherit |

**処理フロー**:
1. GitHub CLI認証確認 → Epic Issue取得
2. 構造化情報の抽出（概要・背景・目標・技術要件・補足）
3. コードベース調査 → 実装規模の見積もり
4. Issue分割（ロジック80行以下、テスト100行以下、5ファイル以下/Issue）
5. ユーザー承認後に `gh issue create` で作成

### Document Writer (`./agents/document_writer.md`)

コードベースを分析してREADME.md、技術仕様書、API仕様書などのドキュメントを自動生成するエージェント。

| 項目 | 内容 |
|------|------|
| name | `document-writer` |
| tools | Bash, Read, Glob, Grep, WebFetch, WebSearch |
| model | inherit |

**対応ドキュメント**:
- README.md - プロジェクト概要、セットアップ、使い方
- 技術仕様書 - アーキテクチャ、設計方針、実装詳細
- API仕様書 - エンドポイント、パラメータ、レスポンス形式

**処理フロー**:
1. ドキュメントタイプと既存ドキュメントの確認
2. コードベース調査（構造、設定、エントリーポイント、主要コンポーネント）
3. タイプ別テンプレートでドキュメント作成
4. ユーザーレビュー → フィードバック反映
5. 承認後に適切な場所へファイル配置

### Pull Request Writer (`./agents/pull_request_writer.md`)

git diffやコミット履歴を分析してPR説明文を自動生成し、レビュー支援、Issue連携、テンプレート適用を行うエージェント。

| 項目 | 内容 |
|------|------|
| name | `pull-request-writer` |
| tools | Bash, Read, Glob, Grep |
| model | inherit |

**機能**:
- PR説明文の自動生成（git diff/logを分析）
- レビューポイントのリストアップ
- Issue番号からPR作成と関連付け
- PRテンプレート適用

**処理フロー**:
1. GitHub CLI認証確認 → ブランチとリモート状態の確認
2. コミット履歴・変更ファイル・コード差分の取得
3. Issue番号検出 → Issue情報取得 → PRテンプレート確認
4. 構造化されたPR説明文を生成 → ユーザーレビュー
5. 承認後に `gh pr create` でPR作成 → Issue連携

### Implementation Strategist (`./agents/implementation_strategist.md`)

Issueを元にコードレベルの具体的な実装戦略を策定するエージェント。

| 項目 | 内容 |
|------|------|
| name | `implementation-strategist` |
| tools | Bash, Read, Write, Glob, Grep, WebSearch |
| model | inherit |

**策定内容**:
- 技術選定とアーキテクチャ設計
- ファイル構成と実装詳細
- 実装順序とフェーズ分け
- 品質保証とリスク対策

**処理フロー**:
1. Issue内容の分析 → コードベース調査
2. 既存パターン・ライブラリ・設定ファイルの確認
3. 技術選定 → アーキテクチャ設計 → ファイル構成策定
4. 実装詳細の具体化（関数設計、データモデル、API定義）
5. 実装順序の計画 → 品質・セキュリティ・リスク評価
6. ユーザーレビュー → 承認後に成果物を出力

### Test Designer (`./agents/test_designer.md`)

Issueと実装戦略を元に、AAAパターンに基づくテスト設計を行うエージェント。

| 項目 | 内容 |
|------|------|
| name | `test-creator` |
| tools | Bash, Read, Write, Glob, Grep, WebSearch |
| model | inherit |

**設計方針**:
- AAAパターン（Arrange, Act, Assert）の採用
- Mockを使わず実インフラ/エミュレータを利用
- Fixtureによる効率的なテスト準備

**処理フロー**:
1. Issue・実装戦略の分析 → テスト対象の特定
2. コードベース調査（既存テスト構造、インフラ設定）
3. テストケース設計（description, infrastructure, AAA）
4. ユーザーレビュー → 承認後に成果物を出力

### Business Analyst (`./agents/business_analyst.md`)

ビジネス要件を分析し、システム要件に落とし込むエージェント。

| 項目 | 内容 |
|------|------|
| name | `business-analyst` |
| tools | Bash, Read, Glob, Grep, WebFetch |
| model | inherit |

**役割**:
- ビジネス課題の明確化
- ステークホルダーニーズの整理
- ビジネス価値の定量化（ROI試算）
- システム要件への変換

**処理フロー**:
1. GitHub CLI認証確認 → Epic Issue取得
2. ビジネス要件分析（課題・ステークホルダー・価値・スコープ）
3. ビジネスニーズの深掘り（4段階の質問フェーズ）
4. システム要件への変換（機能要件・非機能要件）
5. ビジネス分析レポート作成 → Epic Issue統合

---

### Infrastructure Researcher (`./agents/infrastructure_researcher.md`)

既存インフラリソースのIaC管理状況を調査するエージェント。

| 項目 | 内容 |
|------|------|
| name | `infrastructure-researcher` |
| tools | Bash, Read, Glob, Grep, WebFetch |
| model | inherit |

**役割**:
- 既存インフラリソースの把握
- IaCファイルの場所と管理状況の確認
- IaCと実体の差分検出
- インフラ変更の影響範囲特定

**処理フロー**:
1. Epic Issue取得 → 対象プロジェクト特定
2. IaCファイルの検出（Nix, Terraform, K8s, Docker等）
3. リソース実体の確認 → IaC vs実体のギャップ検出
4. インフラ管理状況評価（IaC成熟度レベル1-4）
5. インフラリソース調査結果作成 → Epic Issue返却

---

### Code Researcher (`./agents/code_researcher.md`)

コードベースを複数の観点から調査するエージェント（4つ並列実行）。

| 項目 | 内容 |
|------|------|
| name | `code-researcher` |
| tools | Bash, Read, Glob, Grep, WebSearch |
| model | inherit |

**調査観点**:
1. **pattern** - 関連する既存機能の実装パターン
2. **impact** - 影響を受ける既存コンポーネント
3. **technology** - 使用可能なライブラリとフレームワーク
4. **testing** - 既存のテストコード構造

**処理フロー**:
1. 初期化と入力検証（perspective指定）
2. 観点別の調査実行（4つ並列）
3. 構造化されたYAML出力（${perspective}_research.yaml）

---

### Solution Architect (`./agents/solution_architect.md`)

複数のソリューション案を比較検討し、最適なアーキテクチャを提案するエージェント。

| 項目 | 内容 |
|------|------|
| name | `solution-architect` |
| tools | Bash, Read, Write, Grep, Glob, WebSearch |
| model | inherit |

**役割**:
- ビジネス要件と技術的制約のバランス
- 複数のソリューション案の比較検討（3-5案）
- 最適なアーキテクチャの提案
- トレードオフの明確化

**処理フロー**:
1. 初期化 → 入力エージェント結果の整理
2. 複数エージェント結果の統合分析
3. ソリューション案の生成（最速導入案、最適バランス案、最強耐久案、最低リスク案、革新案）
4. 推奨案の決定（スコアリング、根拠の明確化）
5. 統合レポート作成（Executive Summary含む）

---

### Implementation Issue Enhancer (`./agents/impl_issue_enhancer.md`)

Sub Issueを分析し、implementation-strategistとtest-designerを制御して実装可能性を高めるエージェント。

| 項目 | 内容 |
|------|------|
| name | `impl-issue-enhancer` |
| tools | Bash, Read, Write, Glob, Grep, Task |
| model | inherit |

**役割**:
- Sub Issueの充実度評価と不足情報の特定
- implementation-strategistを起動して実装戦略を策定
- test-designerを起動してテスト設計を作成
- 実装戦略とテスト設計を統合してIssueを強化

**処理フロー**:
1. GitHub CLI認証確認 → 実装Issue取得
2. Issue分析（実装可能性評価、不足情報の特定）
3. implementation-strategist起動 → 実装戦略の策定・品質確認
4. test-designer起動 → テスト設計の作成・品質確認
5. 実装戦略とテスト設計を統合 → ユーザーレビュー → Issue更新

### Code Reviewer (`./agents/code_reviewer.md`)

PR作成前にコード品質をレビューし、DRY原則・凝集性・命名・PR粒度などの観点からフィードバックを提供するエージェント。

| 項目 | 内容 |
|------|------|
| name | `code-reviewer` |
| tools | Bash, Read, Glob, Grep |
| model | inherit |

**レビュー観点**:
- DRY原則（重複コードの検出）
- 凝集性（単一責任原則の遵守）
- 命名規則（明確性と一貫性）
- PR粒度（適切なサイズと論理的まとまり）
- コーディング規約、テストカバレッジ
- パフォーマンス・セキュリティ懸念

**処理フロー**:
1. git diff/変更ファイルの取得 → 既存パターン・規約の確認
2. 観点別レビュー（DRY、凝集性、命名、PR粒度など）
3. 必要に応じてPR分割を提案
4. 優先度別に推奨アクション整理 → ユーザーレビュー
5. レビュー結果を pull-request-writer に引き継ぎ

### Developer (`./agents/developer.md`)

TDD（テスト駆動開発）に基づいて実装を行い、code-reviewerと連携しながら高品質なコードを生成するエージェント。

| 項目 | 内容 |
|------|------|
| name | `developer` |
| tools | Bash, Read, Write, Glob, Grep, WebSearch, Task |
| model | inherit |

**役割**:
- TDDサイクル（Red-Green-Refactor）に基づく実装
- code-reviewerとの連携による継続的な品質改善
- 高凝集疎結合なコード設計
- Epic IssueとImpl Issueを入力として実装とテストを生成

**処理フロー**:
1. Phase 1: 準備・Issue分析 → GitHub CLI認証、Issue取得、コードベース調査
2. Phase 2: テスト実装（TDD: Red） → AAAパターン、実インフラ利用、テスト失敗確認
3. Phase 3: コード実装（TDD: Green） → 最小限の実装、テスト成功確認
4. Phase 4: リファクタリング（TDD: Refactor） → DRY原則、凝集性、命名改善
5. Phase 5: code-reviewer起動 → Task toolでレビュー依頼、YAML出力解析
6. Phase 6: 指摘対応と再確認 → Mustfix対応、修正ループ（最大3回）
7. Phase 7: コミット準備 → 最終テスト、AC確認、git commit実行

**成果物**:
- 実装コード（高凝集疎結合、既存パターン踏襲）
- テストコード（AAAパターン、実インフラ利用、網羅性）
- git commit（構造化されたコミットメッセージ）

**品質基準**:
- 全テストPass
- Acceptance Criteria全満足
- code-reviewer評価Good
- Mustfix全解消
- セキュリティ懸念なし

### エージェントの連携

```
[ユーザーの初期Epic] → [epic-issue-enhancer] → Phase 1: 初期化
                                                      ↓
                                               Phase 2: 分析
                                                      ↓
                                            Phase 2.5: サブエージェント起動
                                                      ↓
                                  +-------------------+-------------------+
                                  |                                       |
                          [business-analyst]                   [infrastructure-researcher]
                                  |                                       |
                          [ビジネス分析レポート]                    [インフラ調査結果]
                                  ↓                                       ↓
                                  +-------------------+-------------------+
                                                      |
                                          [code-researcher x4] (並列実行)
                                                      |
                                              - pattern研究
                                              - impact研究
                                              - technology研究
                                              - testing研究
                                                      ↓
                                               Phase 3: 情報収集
                                                      ↓
                                            Phase 3.5: solution-architect起動
                                                      ↓
                                          +----------+----------+
                                          |                     |
                                  [複数ソリューション案]    [推奨案の決定]
                                          |                     |
                                          +----------+----------+
                                                      ↓
                                               Phase 4: 強化案作成
                                                      ↓
                                               Phase 5: Issue更新
                                                      ↓
                                              [強化済みEpic]
                                                      ↓
                                          [sub-issue-creator] → [Sub Issues]
                                                                       ↓
                                                        [impl-issue-enhancer] (オプション)
                                                                       ↓
                                                          +------------+------------+
                                                          |                         |
                                              [implementation-strategist]  [test-creator]
                                                          |                         |
                                                    [実装戦略]                [テスト設計]
                                                          ↓                         ↓
                                                          +------------+------------+
                                                                       ↓
                                                          [統合された実装Issue]
                                                                       ↓
                                                                  [developer] ← 【NEW】
                                                                       ↓
                                                    Phase 1-4: TDD サイクル（Red-Green-Refactor）
                                                                       ↓
                                                          Phase 5: code-reviewer起動
                                                                       ↓
                                                          Phase 6: 指摘対応（修正ループ）
                                                                       ↓
                                                          Phase 7: コミット準備・実行
                                                                       ↓
                                                          [実装完了・git commit]
                                                                       ↓
                                                        [pull-request-writer] → [PR作成]
                                                                       ↓
                                                           [document-writer] → [ドキュメント]
```

**連携の説明**:
- **epic-issue-enhancer**: Phase 2.5で複数エージェントを並列起動、Phase 3.5でsolution-architectを起動
- **business-analyst**: ビジネス要件を分析してシステム要件に落とし込む
- **infrastructure-researcher**: インフラリソースとIaC管理状況を調査
- **code-researcher x4**: コードベースを4つの観点から並列調査
- **solution-architect**: 全調査結果を統合して最適なソリューションを提案
- **sub-issue-creator**: 完全なEpic Issueを実装単位に分割
- **impl-issue-enhancer**: Sub Issueを分析し、implementation-strategistとtest-creatorを制御して実装可能性を高める（オプション）
- **implementation-strategist**: Sub Issueからコードレベルの実装戦略を策定
- **test-creator**: 実装戦略を元にテスト設計を作成
- **developer**: TDDサイクル（Red-Green-Refactor）に基づく実装、code-reviewerと連携して高凝集疎結合なコードを生成
- **code-reviewer**: DRY原則、凝集性、命名規則、PR粒度などの観点でコード品質をレビュー
- **pull-request-writer**: レビュー結果を踏まえてPRを作成してレビュー支援
- **document-writer**: 必要に応じてドキュメントを生成

---

## エージェント群の位置づけ - 小さなソフトウェアエンジニアリング受託企業として

Claude Codeのカスタムエージェント群は、**小規模なソフトウェアエンジニアリング受託企業**の開発体制を模した設計になっています。
各エージェントは特定の専門性を持つチームメンバーとして機能し、要件定義からリリースまでの一貫した開発フローを実現します。

### チーム構成と役割

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

---

## ソフトウェア開発工程とエージェントの対応

### 開発工程の全体像

Claude Codeのエージェント群は、以下の7つの開発フェーズに対応しています：

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

### 開発工程フローとエージェントの関係

上記の7つのフェーズは、既存の「エージェントの連携」フロー図と以下のように対応しています：

- **Phase 1 (要件定義)**: [ユーザーの初期Epic] → [epic-issue-enhancer] → Phase 2.5サブエージェント起動 → Phase 3.5 solution-architect起動 → Phase 5 Issue更新
- **Phase 2 (基本設計)**: Phase 3.5の solution-architect
- **Phase 3 (要件分割)**: [sub-issue-creator] → [Sub Issues]
- **Phase 4 (詳細設計)**: [impl-issue-enhancer] → implementation-strategist + test-designer
- **Phase 5 (実装)**: [実装作業]
- **Phase 6 (コードレビュー)**: [code-reviewer]
- **Phase 7 (リリース準備)**: [pull-request-writer] + [document-writer]

詳細な連携フローは、上記「エージェントの連携」セクションのフロー図を参照してください。

---

### Phase 1: 要件定義 (Requirements Definition)

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **epic-issue-enhancer** | 必須 | 要件収集の司令塔、サブエージェント制御 | 強化版Epic Issue | 必須セクション完備、sub-issue-creatorで分割可能 |
| business-analyst | オプション | ビジネス要件→システム要件変換 | ビジネス分析レポート (YAML/MD) | ROI試算、ステークホルダー3グループ以上特定 |
| infrastructure-researcher | オプション | インフラ調査、IaC成熟度評価 | インフラ調査結果 (YAML/MD) | IaC成熟度レベル明記、リソース一覧完備 |
| code-researcher x4 | オプション | コードベース調査（並列実行） | 4観点のYAMLレポート | 各観点で3項目以上の発見事項 |
| solution-architect | オプション | 複数案比較、推奨案決定 | ソリューション提案書 (MD) | 3-5案の比較、スコアリング根拠明示 |

#### Phase 1の起動条件

**epic-issue-enhancerの起動条件**:
- ユーザーがEpic Issueを作成済み
- 背景・ゴール・ACのいずれかが不足

**サブエージェントの起動条件** (epic-issue-enhancer Phase 2.5で判断):

| エージェント | 起動条件 | スキップ条件 |
|------------|---------|------------|
| business-analyst | ビジネス価値・ROIが不明確 | Epic Issueに十分なビジネスコンテキストがある |
| infrastructure-researcher | インフラ変更を伴う | インフラ変更がない、または既知 |
| code-researcher x4 | 既存コードへの影響が不明 | 完全新規機能でコードベース調査不要 |
| solution-architect | 複数の技術選択肢がある | 技術スタックが自明（既存パターン踏襲） |

#### Phase 1の品質ゲート

**完了条件** (epic-issue-enhancer Phase 5完了時):
- [ ] Epic Issueに必須セクション（背景・現状・ゴール・実装方針・AC）が全て記載されている
- [ ] ステークホルダーが特定されている（business-analyst起動時）
- [ ] インフラリソースが把握されている（infrastructure-researcher起動時）
- [ ] 既存コードパターンが明確化されている（code-researcher起動時）
- [ ] 推奨ソリューション案が決定されている（solution-architect起動時）
- [ ] ユーザーがEpic Issue内容を承認している

**品質チェックリスト**:
```yaml
Epic Issue品質:
  構造:
    - 背景・動機: 記載あり / なぜ必要かが明確
    - 現状: 記載あり / 具体的な数値・状態を含む
    - ゴール: 記載あり / 達成基準が明確
    - 実装方針: 記載あり / 技術的アプローチが示されている
    - AC: 記載あり / 検証可能な形式

  ビジネス分析 (business-analyst起動時):
    - ROI試算: あり / ペイバック期間が明示
    - ステークホルダー: 3グループ以上特定
    - KPI: 測定可能な形式で定義

  技術分析 (solution-architect起動時):
    - 複数案の比較: 3-5案
    - スコアリング: 客観的評価基準あり
    - リスク評価: 主要リスクと対策が明記
```

---

### Phase 2: 基本設計 (Basic Design / High-Level Design)

**Phase 1との関係**: Phase 1の完了条件を満たした後に移行

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **solution-architect** | 条件付き必須 | アーキテクチャ設計、技術選定 | ソリューション提案書 | 3-5案の比較、トレードオフ明示 |

**起動条件**:
- Phase 1で複数の技術選択肢がある場合
- 新規アーキテクチャ導入を伴う場合
- ビジネス要件と技術要件のトレードオフ検討が必要な場合

**スキップ条件**:
- 既存パターンの踏襲で技術選定が自明
- 小規模な修正・機能追加

#### Phase 2の品質ゲート

**完了条件**:
- [ ] 複数のソリューション案（3-5案）が作成されている
- [ ] 各案のトレードオフが明確化されている
- [ ] 推奨案が客観的な評価基準（スコアリング）に基づいて選定されている
- [ ] アーキテクチャ概要図が作成されている
- [ ] 実装計画（フェーズ分け）が提示されている
- [ ] ユーザーが推奨案を承認している

---

### Phase 3: 要件分割 (Requirements Breakdown)

**Phase 1または2との関係**: Phase 1（またはPhase 2）完了後に移行

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **sub-issue-creator** | 必須 | Epic Issueを実装可能な粒度に分割 | Sub Issues (GitHub Issues) | 1Issueあたりロジック80行、テスト100行、5ファイル以下 |

#### Phase 3の起動条件

- Phase 1 (またはPhase 2) が完了している
- Epic Issueが実装には大きすぎる（複数のPRに分割すべき）
- 依存関係のあるタスクを整理する必要がある

#### Phase 3の品質ゲート

**完了条件**:
- [ ] 各Sub Issueが適切な粒度（80行/100行/5ファイル基準）
- [ ] Issue間の依存関係が明確化されている
- [ ] 実装順序が提案されている
- [ ] 各IssueにParent Issue参照が含まれている
- [ ] ユーザーが分割案を承認している

---

### Phase 4: 詳細設計 (Detailed Design / Low-Level Design)

**Phase 3との関係**: Phase 3で作成されたSub Issue単位で実行（オプション）

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **impl-issue-enhancer** | オプション | Sub Issue詳細化の司令塔 | 強化版Sub Issue | 実装戦略とテスト設計が統合されている |
| code-researcher x4 | オプション | Sub Issue単位のコードベース詳細調査 | 4観点のYAMLレポート | 各観点で3項目以上の発見事項 |
| implementation-strategist | オプション | コードレベルの実装戦略 | 実装戦略 (YAML) | ファイル構成、実装順序、技術選定が明確 |
| test-designer | オプション | AAAパターンのテスト設計 | テスト設計 (YAML) | AAAパターン、実インフラ利用、Fixture活用 |

#### Phase 4の起動条件

**impl-issue-enhancerの起動条件**:
- Sub Issueの実装方針が不明確
- テスト設計が不足している
- 開発者が実装に着手できるレベルまで詳細化が必要

**code-researcher x4の起動条件**:
- Phase 1 で調査しきれなかった詳細が必要
- Sub Issue固有の実装パターン調査が必要
- 影響範囲をより詳細に特定したい
- 使用可能なライブラリ・フレームワークの再確認が必要

**スキップ条件**:
- Sub Issueに十分な実装情報（Technical Approach, Verification Plan）がある
- 既存パターンの踏襲で実装方法が自明
- Phase 1 の調査結果で十分
- 開発者が即座に実装開始できる

#### Phase 4の品質ゲート

**完了条件** (impl-issue-enhancer起動時):
- [ ] 実装戦略（ファイル構成、技術選定、実装順序）が明確
- [ ] テスト設計（AAAパターン、テストケース一覧、Fixture）が完備
- [ ] エラーハンドリング・セキュリティ考慮が記載されている
- [ ] 開発者が即座に実装開始できる詳細度
- [ ] ユーザーが詳細設計を承認している

**完了条件** (code-researcher x4起動時):
- [ ] Sub Issue固有の実装パターンが特定されている
- [ ] 詳細な影響範囲が明確化されている
- [ ] 使用可能なライブラリ・フレームワークが確認されている
- [ ] テスト構造の詳細が把握されている

---

### Phase 5: 実装 (Implementation)

**Phase 3または4との関係**: Phase 3（またはPhase 4）完了後に実装着手

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **developer** | 推奨 | TDDに基づくコード実装、code-reviewerとの連携 | 実装コード、テストコード、git commit | 全テストPass、AC全満足、code-reviewer評価Good |

#### Phase 5の起動条件

**developerの起動条件**:
- Phase 3（Sub Issue作成）または Phase 4（詳細設計）が完了している
- 実装戦略とテスト設計が明確に定義されている
- TDDサイクルに基づく高品質な実装が求められる

**スキップ条件**:
- 開発者が手動で実装する場合
- 小規模な修正（数行程度のバグ修正、ドキュメント修正）
- プロトタイピングやスパイク的な実装

#### Phase 5の品質ゲート

**完了条件**:
- [ ] 全テストがPass（TDDサイクル完了: Red → Green → Refactor）
- [ ] Acceptance Criteriaが全て満たされている
- [ ] code-reviewerの総合評価がGood
- [ ] code-reviewerのMustfixが全て解消されている
- [ ] セキュリティ懸念がNo IssuesまたはMinor Concerns
- [ ] git commitが作成されている（コミットメッセージが構造化されている）
- [ ] ユーザーが実装内容を承認している

**実装時の指針**:
- Sub Issueの Acceptance Criteria を満たす実装
- 実装戦略で示されたファイル構成・技術選定に従う
- テスト設計で示されたAAAパターンでテストコード作成
- TDDサイクル（Red-Green-Refactor）の厳守
- 高凝集疎結合（単一責任原則、依存性注入）の実現
- 既存のコーディング規約に準拠

---

### Phase 6: コードレビュー (Code Review / Quality Assurance)

**Phase 5との関係**: 実装完了後、PR作成前に実行

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **code-reviewer** | 推奨 | コード品質レビュー | コードレビュー結果 (YAML) | DRY、凝集性、命名、PR粒度の全観点評価 |

#### Phase 6の起動条件

- 実装完了（git commitされている）
- PR作成前に品質チェックを行いたい
- DRY原則、凝集性、命名規則、PR粒度の確認が必要

#### Phase 6の品質ゲート

**完了条件**:
- [ ] DRY原則: Pass（重複コードなし）
- [ ] 凝集性: Pass（単一責任原則遵守）
- [ ] 命名規則: Pass（意図が明確、一貫性あり）
- [ ] PR粒度: Appropriate（200-400行程度、単一の責務）
- [ ] テストカバレッジ: Sufficient（新規コードがカバーされている）
- [ ] セキュリティ懸念: No Issues
- [ ] 必須対応 (Mustfix) が全て解決されている

**品質評価基準**:
```yaml
総合評価:
  Good: 全観点がPass、Must対応なし
  Needs Improvement: 一部Warning、Should対応あり
  Needs Major Refactoring: Fail項目あり、Mustfix多数
```

---

### Phase 7: リリース準備 (Release Preparation)

**Phase 6との関係**: コードレビュー完了後（または並行）

#### 責務マトリックス

| エージェント | 起動 | 主な責務 | 成果物 | 品質基準 |
|------------|------|---------|--------|---------|
| **pull-request-writer** | 必須 | PR説明文作成、Issue連携 | GitHub Pull Request | 構造化されたPR説明、レビューポイント明示 |
| document-writer | オプション | 技術文書作成・更新 | README.md / 技術仕様書 / API仕様書 | タイプ別テンプレート準拠、最新情報反映 |

#### Phase 7の起動条件

**pull-request-writerの起動条件**:
- 実装完了、git commitされている
- PRを作成してレビューを依頼したい

**document-writerの起動条件**:
- 新機能追加でREADME更新が必要
- APIエンドポイント追加でAPI仕様書更新が必要
- アーキテクチャ変更で技術仕様書更新が必要

#### Phase 7の品質ゲート

**完了条件** (pull-request-writer):
- [ ] PR説明文が構造化されている（Summary, Changes, Test Plan, Review Points）
- [ ] Issue番号が正しく連携されている
- [ ] レビューポイントが明確にリストアップされている
- [ ] code-reviewerの指摘が反映されている（起動時）
- [ ] CI/CDパイプラインがパスしている

**完了条件** (document-writer起動時):
- [ ] 既存ドキュメントとの整合性が保たれている
- [ ] 最新のコードベースを反映している
- [ ] ユーザーがドキュメント内容を承認している

---

### オプショナルフェーズの判定基準

以下の基準でオプショナルエージェントの起動を判断してください：

| フェーズ | エージェント | 起動すべき条件 | スキップ可能な条件 |
|---------|------------|--------------|-----------------|
| Phase 1 | business-analyst | ROI試算が必要、ステークホルダーが多い | ビジネス価値が自明、小規模な改善 |
| Phase 1 | infrastructure-researcher | インフラ変更を伴う | インフラ変更なし、既知の環境 |
| Phase 1 | code-researcher x4 | 影響範囲が不明、既存パターン調査が必要 | 完全新規機能、影響範囲が自明 |
| Phase 2 | solution-architect | 複数の技術選択肢、トレードオフ検討が必要 | 技術スタックが自明、既存パターン踏襲 |
| Phase 4 | impl-issue-enhancer | 実装方針が不明確、テスト設計が不足 | Sub Issueに十分な情報、既存パターン踏襲 |
| Phase 4 | code-researcher x4 | Phase 1で不足、Sub Issue固有の詳細調査 | Phase 1の調査結果で十分、実装方法が自明 |
| Phase 5 | developer | TDDで品質高く実装、code-reviewer連携 | 開発者が手動実装、小規模な修正 |
| Phase 6 | code-reviewer | 大きな変更、品質確認が必要 | 小規模な修正、自信がある実装 |
| Phase 7 | document-writer | 新機能追加、APIエンドポイント追加 | コード変更のみ、ドキュメント更新不要 |

---

### エージェント間の入出力仕様

各エージェントの成果物は、次のフェーズで活用されます：

#### Phase 1 → Phase 2

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

#### Phase 2 → Phase 3

```
solution-architect (または epic-issue-enhancer)
  └─ 強化版Epic Issue
      ↓
sub-issue-creator
  └─ Sub Issues (GitHub Issues) × N個
```

#### Phase 3 → Phase 4

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

#### Phase 4 → Phase 5

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

#### Phase 5 → Phase 6

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

#### Phase 6 → Phase 7

```
code-reviewer
  └─ code_review_result.yaml
      ↓
pull-request-writer
  └─ GitHub Pull Request
```

#### 並列実行 (Phase 7)

```
実装済みコード
  ├→ pull-request-writer → GitHub PR
  └→ document-writer → README.md / 技術仕様書 / API仕様書
```

---

### 開発工程のベストプラクティス

#### 1. フェーズのスキップ判断

- **Phase 1のサブエージェント**: Epic Issueの情報充実度で判断
- **Phase 2 (solution-architect)**: 技術選択肢の数で判断
- **Phase 4 (impl-issue-enhancer)**: Sub Issueの詳細度で判断
- **Phase 4 (code-researcher x4)**: Phase 1の調査結果の充実度とSub Issue固有の調査必要性で判断
- **Phase 5 (developer)**: 実装方法の明確性と品質要求で判断
- **Phase 6 (code-reviewer)**: 変更規模と品質要求で判断

#### 2. 品質ゲートの遵守

各フェーズの完了条件を満たさずに次フェーズに進まないこと。
特に以下は厳守：
- Phase 1: 必須セクション完備
- Phase 2: 推奨案の決定と承認
- Phase 3: 適切な粒度での分割
- Phase 4: 実装戦略とテスト設計の完備
- Phase 6: 必須対応 (Mustfix) の全解決

#### 3. ユーザー確認ポイントの活用

各エージェントには複数のユーザー確認ポイント [1], [2], ... があります。
これらを省略せず、ユーザーの意図を正確に反映すること。

#### 4. 並列処理の活用

- **Phase 1 Phase 2.5**: business-analyst, infrastructure-researcher, code-researcher x4 を並列起動
- **Phase 4**:
  - code-researcher x4 を並列起動可能（必要な場合）
  - implementation-strategist と test-designer は順次実行（test-designerはimplementation-strategistの出力を参照）
- **Phase 7**: pull-request-writer と document-writer は並列実行可能

---

### トラブルシューティング

#### Q1: Phase 1でサブエージェントをスキップしたが、Phase 2で情報不足が判明した

**対処**: Phase 1に戻り、epic-issue-enhancerを再起動して不足エージェントを起動

#### Q2: Phase 4をスキップしたが、実装時に設計が不明確だった

**対処**: impl-issue-enhancerを後から起動し、Sub Issueを強化

#### Q2-1: Phase 1でcode-researcherを起動したが、Phase 4で詳細情報が不足していた

**対処**: Phase 4でcode-researcher x4を再起動し、Sub Issue固有の詳細調査を実施

#### Q3: code-reviewerでMustfixが多数検出された

**対処**: 実装を修正し、code-reviewerを再実行。Pass後にPhase 7へ

#### Q4: PRが大きすぎてレビュー困難

**対処**: code-reviewerの「PR粒度」評価で分割提案を確認し、複数PRに分割

---

### まとめ

Claude Codeのエージェント群は、ソフトウェア開発の全工程をカバーする**小さなソフトウェアエンジニアリング受託企業**として機能します。

**主な価値**:
1. **完全性**: 要件定義からリリースまでの一貫したフロー
2. **品質**: 各フェーズの品質ゲートによる高品質な成果物
3. **柔軟性**: オプショナルフェーズによる状況に応じた最適化
4. **透明性**: ユーザー確認ポイントでの進捗確認と意思決定
5. **再現性**: 標準化されたプロセスによる安定した品質

このフレームワークを活用することで、ユーザーは「何をいつ起動すべきか」を明確に判断でき、高品質なソフトウェア開発を実現できます。