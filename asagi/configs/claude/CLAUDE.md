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
                                                                  [実装作業]
                                                                       ↓
                                                              [code-reviewer] → [コード品質チェック]
                                                                       ↓
                                                          (必要に応じてPR分割・修正)
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
- **実装作業**: 実装戦略とテスト設計に基づいて実装
- **code-reviewer**: DRY原則、凝集性、命名規則、PR粒度などの観点でコード品質をレビュー
- **pull-request-writer**: レビュー結果を踏まえてPRを作成してレビュー支援
- **document-writer**: 必要に応じてドキュメントを生成
