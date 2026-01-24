# Quality and Testing Guidelines

このドキュメントは、品質基準、TDD（テスト駆動開発）、code-reviewer修正ループに関するルールを定義します。

## 目次

1. [品質ゲート (Quality Gates)](#1-品質ゲート-quality-gates)
2. [TDD (Red-Green-Refactor)](#2-tdd-red-green-refactor)
3. [code-reviewer 修正ループ](#3-code-reviewer-修正ループ)

---

## 1. 品質ゲート (Quality Gates)

### 完了条件のチェックリスト形式

各フェーズの完了条件は、検証可能なチェックリスト形式で記載します。

```markdown
### Phase 1完了条件

- [ ] Epic Issueに必須セクション（背景・現状・ゴール・実装方針・AC）が全て記載されている
- [ ] ステークホルダーが特定されている（business-analyst起動時）
- [ ] インフラリソースが把握されている（infrastructure-researcher起動時)
- [ ] 既存コードパターンが明確化されている（code-researcher起動時）
- [ ] 推奨ソリューション案が決定されている（solution-architect起動時）
- [ ] ユーザーがEpic Issue内容を承認している
```

### 評価値の標準化

品質評価には、以下の標準化された評価値を使用します：

#### 状態フィールド

```yaml
# 3段階評価
status: Pass / Warning / Fail

# 総合評価
overall: Good / Needs Improvement / Needs Major Refactoring

# 充足度
coverage: Sufficient / Insufficient / Missing

# セキュリティ
security: No Issues / Minor Concerns / Major Concerns / Critical Issues

# PR粒度
pr_size: Appropriate / Too Large / Too Small
```

### ✅ Good Example

```yaml
code_review_result:
  overall: Good
  dry_principle:
    status: Pass
    findings: []
  cohesion:
    status: Pass
    findings: []
  naming:
    status: Pass
    findings: []
  pr_granularity:
    status: Appropriate
    line_count: 250
  security:
    status: No Issues
```

### ❌ Bad Example

```yaml
code_review_result:
  overall: OK  # 非標準の評価値
  dry: true  # 構造化されていない
  naming: "good"  # 標準外の値
```

### 優先度レベルの定義

指摘事項は、以下の3段階の優先度で分類します：

#### 必須対応 (Mustfix / Must)

- セキュリティ問題（Critical Issues）
- 重要な機能不足
- Acceptance Criteria未達成
- 重大なバグ

#### 推奨対応 (Should)

- パフォーマンス改善
- コード品質向上（DRY原則違反、凝集性の問題）
- テストカバレッジ拡大
- 命名規則の改善

#### 検討事項 (Nice to have)

- マイナーな改善提案
- ドキュメント充実
- リファクタリング候補

### YAMLテンプレート（品質ゲート）

```yaml
quality_gate:
  phase: Phase 1
  completion_criteria:
    - item: Epic Issueに必須セクション完備
      status: Pass / Fail
    - item: ステークホルダー特定済み
      status: Pass / Fail
    - item: ユーザー承認取得
      status: Pass / Fail
  blockers:
    - blocker: 必須セクション欠落
      severity: Mustfix
  recommendations:
    - recommendation: ビジネス価値の定量化
      severity: Should
```

### チェックリスト

- [ ] 完了条件が検証可能な形式で記載されている
- [ ] 評価値が標準化された値を使用している
- [ ] 優先度レベル（Mustfix/Should/Nice to have）が明示されている
- [ ] ブロッカーとなる必須対応が特定されている

### 参照

- [`agents/epic_issue_enhancer.md`](../agents/epic_issue_enhancer.md) - Phase 1完了条件の例
- [`agents/code_reviewer.md`](../agents/code_reviewer.md) - 品質評価の標準化

---

## 2. TDD (Red-Green-Refactor)

### TDDサイクルの厳守

すべてのコード実装は、以下の**Red-Green-Refactor**サイクルに従います：

```
Phase 2 (Red): 失敗するテストを書く
  ↓
Phase 3 (Green): 最小限の実装でテストをPassさせる
  ↓
Phase 4 (Refactor): 品質を向上させる（DRY原則、凝集性、命名）
```

### Phase 2: Red（失敗するテスト）

#### 必須要件

- **AAAパターン必須**: Arrange, Act, Assert の明確な分離
- **Mock不使用**: Testcontainers、Emulator、実インフラを利用
- **失敗確認**: テストが期待通り失敗することを確認

#### ✅ Good Example

```python
import pytest
from testcontainers.postgres import PostgresContainer

def test_user_authentication_with_valid_credentials():
    # Arrange: テスト用データベース準備（Testcontainers使用）
    with PostgresContainer("postgres:16") as postgres:
        db = setup_database(postgres.get_connection_url())
        user = create_test_user(db, username="testuser", password="password123")

        # Act: 認証処理を実行
        result = authenticate(db, username="testuser", password="password123")

        # Assert: 認証成功を検証
        assert result.is_authenticated == True
        assert result.user_id == user.id
```

#### ❌ Bad Example

```python
def test_user_authentication():
    # Mock使用（実インフラを使っていない）
    mock_db = Mock()
    mock_db.query.return_value = Mock(id=1, username="testuser")

    # AAAパターンの分離がない
    result = authenticate(mock_db, "testuser", "password123")
    assert result.is_authenticated == True
```

### Phase 3: Green（最小限の実装）

#### 必須要件

- **テストをPassさせるだけ**: 過度な実装を避ける
- **段階的に実装**: テストケース1個ずつ実装
- **テスト実行**: 各実装後にテストがPassすることを確認

#### ✅ Good Example

```python
def authenticate(db, username: str, password: str) -> AuthResult:
    """ユーザー認証を行う（最小限の実装）"""
    user = db.query(User).filter_by(username=username).first()

    if user is None:
        return AuthResult(is_authenticated=False, user_id=None)

    if user.password == password:  # 最初はシンプルに
        return AuthResult(is_authenticated=True, user_id=user.id)

    return AuthResult(is_authenticated=False, user_id=None)
```

### Phase 4: Refactor（品質向上）

#### 必須要件

- **DRY原則**: 重複コードの削除
- **凝集性**: 単一責任原則の遵守
- **命名**: 意図が明確な変数・関数名
- **テスト維持**: リファクタリング後もテストがPass

#### ✅ Good Example（Refactor後）

```python
def authenticate(db, username: str, password: str) -> AuthResult:
    """ユーザー認証を行う"""
    user = find_user_by_username(db, username)

    if user is None:
        return authentication_failed()

    if verify_password(user, password):
        return authentication_success(user)

    return authentication_failed()

def find_user_by_username(db, username: str) -> Optional[User]:
    """ユーザー名でユーザーを検索"""
    return db.query(User).filter_by(username=username).first()

def verify_password(user: User, password: str) -> bool:
    """パスワードを検証（将来的にハッシュ化対応）"""
    return user.password == password

def authentication_success(user: User) -> AuthResult:
    """認証成功結果を返す"""
    return AuthResult(is_authenticated=True, user_id=user.id)

def authentication_failed() -> AuthResult:
    """認証失敗結果を返す"""
    return AuthResult(is_authenticated=False, user_id=None)
```

### テストの非機能要件

#### ネストの深さ

- **3階層以下**: テストコードのネストは3階層までに制限

#### 関数・クラスサイズ

- **関数50行以下**: 1つの関数は50行以下
- **クラス300行以下**: 1つのクラスは300行以下
- **超過時**: 関数分割、クラス分割を検討

### YAMLテンプレート（TDDテストケース）

```yaml
test_case:
  description: ユーザー認証：有効な認証情報でログイン成功
  infrastructure: Testcontainers (PostgreSQL)
  arrange: |
    # テスト用データベース準備
    with PostgresContainer("postgres:16") as postgres:
        db = setup_database(postgres.get_connection_url())
        user = create_test_user(db, username="testuser", password="password123")
  act: |
    # 認証処理を実行
    result = authenticate(db, username="testuser", password="password123")
  assert: |
    # 認証成功を検証
    assert result.is_authenticated == True
    assert result.user_id == user.id
```

### チェックリスト

- [ ] AAAパターンで記述されている（Arrange, Act, Assert）
- [ ] Mockを使っていない（実インフラ、Testcontainers、Emulator利用）
- [ ] 関数が50行以下
- [ ] クラスが300行以下
- [ ] ネストが3階層以下
- [ ] Red → Green → Refactorのサイクルを経ている
- [ ] テストがPassしている

### 参照

- [`agents/test_designer.md`](../agents/test_designer.md) - AAAパターンとテスト設計
- [`agents/developer.md`](../agents/developer.md) - TDDサイクルの実装例（Phase 2-4）

---

## 3. code-reviewer 修正ループ

### ループ制御

code-reviewerの指摘対応は、**最大3回**のループで制御します。

```
初回レビュー → 修正1回目 → レビュー2回目 → 修正2回目 → レビュー3回目 → 修正3回目
  ↓             ↓              ↓               ↓              ↓               ↓
Pass?         Pass?          Pass?           Pass?          Pass?          ユーザーエスカレーション
```

### 終了条件

以下の条件を**すべて**満たした場合、ループ終了（Pass）：

#### チェックリスト

- [ ] 総合評価: Good
- [ ] Mustfix: なし（すべて解消済み）
- [ ] セキュリティ: No Issues または Minor Concerns
- [ ] DRY原則: Pass
- [ ] 凝集性: Pass
- [ ] 命名規則: Pass
- [ ] PR粒度: Appropriate

### ✅ Good Example（Pass条件満たす）

```yaml
code_review_result:
  overall: Good
  mustfix_items: []
  dry_principle:
    status: Pass
  cohesion:
    status: Pass
  naming:
    status: Pass
  pr_granularity:
    status: Appropriate
    line_count: 280
  security:
    status: No Issues
```

### ❌ Bad Example（Pass条件満たさない）

```yaml
code_review_result:
  overall: Needs Improvement
  mustfix_items:
    - セキュリティ: SQLインジェクション脆弱性
  dry_principle:
    status: Warning
  security:
    status: Critical Issues  # Mustfix
```

### 修正ループの実施例

#### 1回目レビュー

```yaml
code_review_result:
  overall: Needs Improvement
  mustfix_items:
    - DRY原則: 認証ロジックが3箇所で重複
  should_items:
    - 命名規則: 関数名 `auth` → `authenticate_user` に変更推奨
```

**開発者の対応**: DRY原則違反を修正、関数名を変更

#### 2回目レビュー

```yaml
code_review_result:
  overall: Good
  mustfix_items: []
  should_items: []
  dry_principle:
    status: Pass
  naming:
    status: Pass
```

**結果**: Pass（ループ終了）

### 3回超過時のエスカレーション

修正ループが3回を超えた場合、**ユーザーエスカレーション**を実施：

1. ユーザーに現在の状況を提示
2. 推奨アクション提示（設計見直し、Issue分割検討）
3. ユーザー判断を仰ぐ

#### エスカレーション例

```markdown
## ユーザーエスカレーション

修正ループが3回を超えましたが、以下のMustfixが未解決です：

### 未解決のMustfix

1. セキュリティ: SQLインジェクション脆弱性が残存
2. DRY原則: 認証ロジックの重複が完全に解消されていない

### 推奨アクション

1. **設計見直し**: 認証機能を独立したサービスクラスに分離
2. **Issue分割**: セキュリティ対策を別Issueとして分離し、専門家レビューを依頼

ユーザー判断をお願いします。
```

### YAMLテンプレート（code-review結果）

```yaml
code_review_result:
  overall: Good / Needs Improvement / Needs Major Refactoring
  loop_count: 1  # 修正ループ回数
  mustfix_items:
    - item: セキュリティ問題の説明
      location: ファイル名:行番号
  should_items:
    - item: 推奨改善の説明
      location: ファイル名:行番号
  dry_principle:
    status: Pass / Warning / Fail
    findings:
      - finding: 発見事項
  cohesion:
    status: Pass / Warning / Fail
    findings: []
  naming:
    status: Pass / Warning / Fail
    findings: []
  pr_granularity:
    status: Appropriate / Too Large / Too Small
    line_count: 280
  security:
    status: No Issues / Minor Concerns / Major Concerns / Critical Issues
    findings: []
```

### チェックリスト

- [ ] 修正ループ回数をカウントしている
- [ ] 3回超過時にユーザーエスカレーション
- [ ] 総合評価がGood
- [ ] Mustfixがすべて解消されている
- [ ] セキュリティがNo IssuesまたはMinor Concerns

### 参照

- [`agents/code_reviewer.md`](../agents/code_reviewer.md) - レビュー基準とループ制御
- [`agents/developer.md`](../agents/developer.md) - Phase 5-6での修正ループ実装

---

## まとめ

Quality and Testing Guidelinesでは、以下の3つの主要な領域をカバーしています：

1. **品質ゲート**: 検証可能なチェックリスト、標準化された評価値、優先度レベル
2. **TDD (Red-Green-Refactor)**: AAAパターン、Mock不使用、段階的実装
3. **code-reviewer 修正ループ**: 最大3回のループ制御、終了条件、エスカレーション

これらのガイドラインに従うことで、高品質なコードと持続可能な開発プロセスが実現されます。
