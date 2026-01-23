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
[ユーザーの初期Epic] → [epic-issue-enhancer] → [強化済みEpic]
                                                      ↓
                                          [sub-issue-creator] → [Sub Issues]
                                                                       ↓
                                                    [implementation-strategist] → [実装戦略]
                                                                       ↓
                                                              +--------+--------+
                                                              |                 |
                                                        [test-creator]    [実装作業]
                                                              |                 |
                                                        [テスト設計]       [コード実装]
                                                              ↓                 ↓
                                                              +--------+--------+
                                                                       ↓
                                                              [code-reviewer] → [コード品質チェック]
                                                                       ↓
                                                          (必要に応じてPR分割・修正)
                                                                       ↓
                                                        [pull-request-writer] → [PR作成]
                                                                       ↓
                                                           [document-writer] → [ドキュメント]
```

- **epic-issue-enhancer**: 不完全なEpic Issueを構造化・補完
- **sub-issue-creator**: 完全なEpic Issueを実装単位に分割
- **implementation-strategist**: Sub Issueからコードレベルの実装戦略を策定
- **test-creator**: 実装戦略を元にテスト設計を作成
- **実装作業**: 実装戦略とテスト設計に基づいて実装
- **code-reviewer**: DRY原則、凝集性、命名規則、PR粒度などの観点でコード品質をレビュー
- **pull-request-writer**: レビュー結果を踏まえてPRを作成してレビュー支援
- **document-writer**: 必要に応じてドキュメントを生成
