# Development Process Rules

このドキュメントは、開発工程の7フェーズ、GitHub CLI・git使用ルール、コードベース調査に関するルールを定義します。

## 目次

1. [開発工程の7フェーズ](#1-開発工程の7フェーズ)
2. [GitHub CLI (gh) 使用ルール](#2-github-cli-gh-使用ルール)
3. [git操作の厳密性](#3-git操作の厳密性)
4. [コードベース調査の4観点](#4-コードベース調査の4観点)

---

## 1. 開発工程の7フェーズ

### フェーズ構造

すべてのソフトウェア開発は、以下の7フェーズで構成されます：

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

### スキップ判定基準

各フェーズのオプショナルエージェントは、以下の基準でスキップ判定を行います：

| フェーズ | エージェント | 起動すべき条件 | スキップ可能条件 |
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

### Phase 1完了条件（要件定義）

#### チェックリスト

- [ ] Epic Issueに必須セクション（背景・現状・ゴール・実装方針・AC）が完備
- [ ] ステークホルダーが特定されている（business-analyst起動時）
- [ ] インフラリソースが把握されている（infrastructure-researcher起動時）
- [ ] 既存コードパターンが明確化されている（code-researcher起動時）
- [ ] 推奨ソリューション案が決定されている（solution-architect起動時）
- [ ] ユーザーがEpic Issue内容を承認している

### Phase 2完了条件（基本設計）

#### チェックリスト

- [ ] 複数のソリューション案（3-5案）が作成されている
- [ ] 各案のトレードオフが明確化されている
- [ ] 推奨案が客観的な評価基準（スコアリング）に基づいて選定されている
- [ ] アーキテクチャ概要図が作成されている
- [ ] 実装計画（フェーズ分け）が提示されている
- [ ] ユーザーが推奨案を承認している

### Phase 3完了条件（要件分割）

#### チェックリスト

- [ ] 各Sub Issueが適切な粒度（80行/100行/5ファイル基準）
- [ ] Issue間の依存関係が明確化されている
- [ ] 実装順序が提案されている
- [ ] 各IssueにParent Issue参照が含まれている
- [ ] ユーザーが分割案を承認している

### Phase 4完了条件（詳細設計）

#### チェックリスト（impl-issue-enhancer起動時）

- [ ] 実装戦略（ファイル構成、技術選定、実装順序）が明確
- [ ] テスト設計（AAAパターン、テストケース一覧、Fixture）が完備
- [ ] エラーハンドリング・セキュリティ考慮が記載されている
- [ ] 開発者が即座に実装開始できる詳細度
- [ ] ユーザーが詳細設計を承認している

### Phase 5完了条件（実装）

#### チェックリスト

- [ ] 全テストがPass（TDDサイクル完了: Red → Green → Refactor）
- [ ] Acceptance Criteriaが全て満たされている
- [ ] code-reviewerの総合評価がGood
- [ ] code-reviewerのMustfixが全て解消されている
- [ ] セキュリティ懸念がNo IssuesまたはMinor Concerns
- [ ] git commitが作成されている（コミットメッセージが構造化されている）
- [ ] ユーザーが実装内容を承認している

### Phase 6完了条件（コードレビュー）

#### チェックリスト

- [ ] DRY原則: Pass（重複コードなし）
- [ ] 凝集性: Pass（単一責任原則遵守）
- [ ] 命名規則: Pass（意図が明確、一貫性あり）
- [ ] PR粒度: Appropriate（200-400行程度、単一の責務）
- [ ] テストカバレッジ: Sufficient（新規コードがカバーされている）
- [ ] セキュリティ懸念: No Issues
- [ ] 必須対応 (Mustfix) が全て解決されている

### Phase 7完了条件（リリース準備）

#### チェックリスト（pull-request-writer）

- [ ] PR説明文が構造化されている（Summary, Changes, Test Plan, Review Points）
- [ ] Issue番号が正しく連携されている
- [ ] レビューポイントが明確にリストアップされている
- [ ] code-reviewerの指摘が反映されている（起動時）
- [ ] CI/CDパイプラインがパスしている

#### チェックリスト（document-writer起動時）

- [ ] 既存ドキュメントとの整合性が保たれている
- [ ] 最新のコードベースを反映している
- [ ] ユーザーがドキュメント内容を承認している

### 参照

- [`configs/claude/CLAUDE.md`](../CLAUDE.md) - ソフトウェア開発工程とエージェントの対応
- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 1の完全な例
- [`agents/developer.md`](../agents/developer.md) - Phase 5-6の完全な例

---

## 2. GitHub CLI (gh) 使用ルール

### 必須チェック

すべてのエージェントは、GitHub操作の前に以下のチェックを実施します：

#### Phase開始時

```bash
# 認証状態確認
gh auth status

# 期待される出力
✓ Logged in to github.com as username
```

#### Issue操作前

```bash
# Issue取得
gh issue view ${ISSUE_NUMBER}

# Issueリスト取得
gh issue list --limit 10
```

#### コミット前

```bash
# 状態確認
git status

# 変更内容確認
git diff

# ステージングされた変更確認
git diff --staged
```

### ✅ Good Example

```markdown
### Phase 1: 初期化

1. GitHub CLI認証確認
   ```bash
   gh auth status
   ```

2. Epic Issue取得
   ```bash
   gh issue view 123
   ```
```

### ❌ Bad Example

```markdown
### Phase 1: 初期化

1. Issueを取得（認証確認なし）
```

### Issue更新の原則

#### ✅ Accept: `gh issue edit` 使用

```bash
# Issue本文更新
gh issue edit 123 --body "$(cat updated_issue.md)"

# Issueタイトル更新
gh issue edit 123 --title "新しいタイトル"

# ラベル追加
gh issue edit 123 --add-label "enhancement"
```

#### ❌ Deny: Web UIでの直接編集

- GitHubのWeb UIから直接編集しない
- 常に `gh issue edit` コマンドを使用
- トレーサビリティを確保

### チェックリスト

- [ ] `gh auth status` で認証確認済み
- [ ] `gh issue view` でIssue内容を取得
- [ ] `gh issue edit` でIssue更新（直接編集しない）
- [ ] コミット前に `git status` と `git diff` で確認

### 参照

- [`skills/manage__git_github/SKILL.md`](../skills/manage__git_github/SKILL.md) - GitHub CLI使用方法
- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - gh認証確認の例

---

## 3. git操作の厳密性

### 禁止操作

以下のgit操作は**禁止**されています：

#### ❌ Deny

```bash
# 1. 直接push（pull-request-writerに引き継ぎ）
git push origin main

# 2. commit --amend（新規コミット作成）
git commit --amend -m "修正"

# 3. 対話型rebase（対話型操作不可）
git rebase -i HEAD~3

# 4. force push（データ損失リスク）
git push --force

# 5. hard reset（履歴消去）
git reset --hard HEAD~1
```

### 推奨操作

#### ✅ Accept

```bash
# 1. 構造化されたコミットメッセージ
git commit -m "$(cat <<'EOF'
feat: ユーザー認証機能を追加

- Testcontainersを使用した統合テスト
- AAAパターンでテスト記述
- パスワードハッシュ化対応

Refs: #123
EOF
)"

# 2. ステージング確認
git add src/auth.py tests/test_auth.py
git status

# 3. 変更内容確認
git diff --staged
```

### コミットメッセージ構造

すべてのコミットメッセージは、以下の構造に従います：

```
type: 簡潔な説明（50文字以内）

詳細な説明（必要に応じて）
- 変更内容1
- 変更内容2

Refs: #123
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

#### type の種類

| type | 説明 | 例 |
|------|------|-----|
| feat | 新機能追加 | `feat: ユーザー認証機能を追加` |
| fix | バグ修正 | `fix: ログイン時のエラーハンドリングを修正` |
| refactor | リファクタリング | `refactor: 認証ロジックを独立したサービスに分離` |
| test | テスト追加・修正 | `test: 認証機能の統合テストを追加` |
| docs | ドキュメント更新 | `docs: README.mdにセットアップ手順を追加` |
| chore | ビルド・ツール変更 | `chore: 依存パッケージを更新` |

### ✅ Good Example

```bash
git commit -m "$(cat <<'EOF'
feat: ユーザー認証機能を追加

- PostgreSQL Testcontainersを使用した統合テスト
- AAAパターンでテスト記述（Arrange, Act, Assert）
- パスワードハッシュ化対応（bcrypt使用）
- 認証失敗時のエラーメッセージ改善

Refs: #123
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### ❌ Bad Example

```bash
# 構造化されていない
git commit -m "認証機能追加"

# typeがない
git commit -m "ユーザー認証機能を追加"

# Issue参照がない
git commit -m "feat: ユーザー認証機能を追加"
```

### チェックリスト

- [ ] 禁止操作（push, amend, rebase -i, force push, hard reset）を使用していない
- [ ] コミットメッセージにtypeが含まれている
- [ ] 簡潔な説明が50文字以内
- [ ] Issue番号が含まれている（Refs: #123）
- [ ] HEREDOCを使用して構造化されている

### 参照

- [`skills/manage__git_github/SKILL.md`](../skills/manage__git_github/SKILL.md) - git操作のベストプラクティス
- [`agents/developer.md`](../agents/developer.md) - Phase 7でのコミット作成

---

## 4. コードベース調査の4観点

### code-researcherの調査項目

code-researcherエージェントは、以下の4つの観点でコードベースを並列調査します：

| 観点 | 英語名 | 調査内容 |
|------|--------|---------|
| **パターン** | pattern | 関連する既存機能の実装パターン |
| **影響範囲** | impact | 影響を受ける既存コンポーネント |
| **技術スタック** | technology | 使用可能なライブラリとフレームワーク |
| **テスト構造** | testing | 既存のテストコード構造 |

### 調査手法

#### 1. パターン調査 (pattern)

```bash
# 関連する既存機能を検索
grep -r "authenticate" src/

# 類似のコンポーネント構造を確認
find src/components -name "*Auth*"

# 既存のサービスクラスを確認
ls src/services/
```

#### 2. 影響範囲調査 (impact)

```bash
# 依存関係を確認
grep -r "import.*auth" src/

# 影響を受けるファイルを特定
git grep "User" src/
```

#### 3. 技術スタック調査 (technology)

```bash
# プロジェクト設定ファイルを確認
cat package.json  # Node.js
cat Cargo.toml    # Rust
cat pyproject.toml  # Python

# 既存のライブラリ使用状況
grep "import" src/**/*.py | sort | uniq
```

#### 4. テスト構造調査 (testing)

```bash
# テストディレクトリ構造を確認
tree tests/

# 既存のテストパターンを確認
grep -r "def test_" tests/

# テストフレームワークを確認
cat tests/conftest.py  # pytest
```

### 調査手法チェックリスト

#### ディレクトリ構造確認

- [ ] `tree` コマンドでディレクトリ構造を確認
- [ ] `ls -la` で各ディレクトリの内容を確認
- [ ] 既存の命名規則を把握

#### 設定ファイル確認

- [ ] `package.json` / `Cargo.toml` / `pyproject.toml` 確認
- [ ] `.eslintrc` / `.prettierrc` でコーディング規約確認
- [ ] `tsconfig.json` / `pytest.ini` で開発環境確認

#### 既存コード確認

- [ ] 類似機能の実装を `grep -r` で検索
- [ ] 既存のクラス・関数構造を把握
- [ ] 依存関係を `import` 文で確認

#### テストコード確認

- [ ] テストディレクトリ構造を確認
- [ ] 既存のテストパターンを把握
- [ ] テストフレームワーク（pytest, jest, etc）を確認

### YAMLテンプレート（調査結果）

```yaml
# pattern_research_epic_123.yaml
---
perspective: pattern
epic_number: 123
findings:
  - finding: 既存の認証機能は src/auth/authenticator.py に実装
    details: |
      - JWT認証を使用
      - bcryptでパスワードハッシュ化
      - Redisでセッション管理
  - finding: サービスクラスパターンを採用
    details: |
      - src/services/ 配下にビジネスロジック
      - 各サービスは単一責任原則を遵守
recommendations:
  - recommendation: 既存のAuthenticatorクラスを拡張
    rationale: 新規実装よりも既存パターンを踏襲して一貫性を保つ
---
```

```yaml
# impact_scope_epic_123.yaml
---
perspective: impact
epic_number: 123
findings:
  - finding: 影響を受けるコンポーネント
    components:
      - src/api/routes/auth.py
      - src/models/user.py
      - src/middleware/auth_middleware.py
  - finding: 依存関係
    dependencies:
      - PyJWT
      - bcrypt
      - redis
recommendations:
  - recommendation: ミドルウェアの更新が必要
    rationale: 認証フローの変更に伴い、ミドルウェアの修正が必要
---
```

### チェックリスト

- [ ] 4観点すべてで調査を実施
- [ ] 各観点で3項目以上の発見事項
- [ ] 推奨事項が具体的で実行可能
- [ ] YAML形式で構造化されている
- [ ] Epic番号/Issue番号が含まれている

### 参照

- [`agents/code_researcher.md`](../agents/code_researcher.md) - 4観点並列調査の詳細
- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 2.5での調査実施例

---

## まとめ

Development Process Rulesでは、以下の4つの主要な領域をカバーしています：

1. **開発工程の7フェーズ**: スキップ判定基準、各フェーズの完了条件
2. **GitHub CLI使用ルール**: 認証確認、Issue更新、トレーサビリティ
3. **git操作の厳密性**: 禁止操作、推奨操作、コミットメッセージ構造
4. **コードベース調査の4観点**: pattern, impact, technology, testing

これらのルールに従うことで、標準化された開発プロセスと高品質な成果物が実現されます。
