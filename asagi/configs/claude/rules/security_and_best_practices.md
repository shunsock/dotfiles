# Security and Best Practices

このドキュメントは、セキュリティ、パフォーマンス、エラーハンドリング、ドキュメント記述に関するベストプラクティスを定義します。

## 目次

1. [セキュリティチェック項目](#1-セキュリティチェック項目)
2. [パフォーマンスチェック項目](#2-パフォーマンスチェック項目)
3. [エラーハンドリング](#3-エラーハンドリング)
4. [ドキュメント記述の原則](#4-ドキュメント記述の原則)

---

## 1. セキュリティチェック項目

### 必須対応

すべてのコード実装は、以下のセキュリティチェック項目を満たす必要があります：

| 項目 | 説明 | 優先度 |
|------|------|--------|
| 入力バリデーション | ユーザー入力をすべて検証 | Critical |
| 機密情報の環境変数化 | APIキー、パスワードをハードコードしない | Critical |
| SQLインジェクション対策 | パラメータ化クエリを使用 | Critical |
| XSS対策 | HTMLエスケープ、CSP設定 | Critical |
| 認証・認可 | 適切な権限チェック | Critical |
| HTTPS通信 | 暗号化通信の強制 | High |
| ログ出力の制御 | 機密情報をログに出力しない | High |

### 優先度レベル

| レベル | 対応 | 例 |
|--------|------|-----|
| Critical Issues | **修正必須** | SQLインジェクション、XSS、認証バイパス |
| Major Concerns | 修正推奨（リリース前） | 不適切なエラーメッセージ、弱いパスワードポリシー |
| Minor Concerns | 対応検討 | ログ出力の改善、HTTPS強制の検討 |
| No Issues | OK | セキュリティ問題なし |

### ✅ Good Example

```python
import os
from typing import Optional
from sqlalchemy.orm import Session

def get_user_by_id(db: Session, user_id: int) -> Optional[User]:
    """ユーザーIDでユーザーを取得"""
    # ✅ パラメータ化クエリでSQLインジェクション対策
    return db.query(User).filter(User.id == user_id).first()

def authenticate_user(db: Session, username: str, password: str) -> Optional[User]:
    """ユーザー認証"""
    # ✅ 機密情報を環境変数から取得
    secret_key = os.environ.get("SECRET_KEY")
    if not secret_key:
        raise ValueError("SECRET_KEY environment variable is not set")

    # ✅ 入力バリデーション
    if not username or not password:
        return None

    user = get_user_by_username(db, username)
    if user and verify_password(password, user.hashed_password):
        return user

    return None

def sanitize_html(user_input: str) -> str:
    """HTMLエスケープでXSS対策"""
    # ✅ HTMLエスケープ
    import html
    return html.escape(user_input)
```

### ❌ Bad Example

```python
def get_user_by_id(db, user_id):
    # ❌ SQLインジェクション脆弱性
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query).fetchone()

def authenticate_user(username, password):
    # ❌ ハードコードされた機密情報
    secret_key = "sk-1234567890abcdef"

    # ❌ 入力バリデーションなし
    user = get_user_by_username(username)
    if user.password == password:  # ❌ 平文パスワード比較
        return user

def render_user_input(user_input):
    # ❌ XSS脆弱性
    return f"<div>{user_input}</div>"
```

### チェックリスト

- [ ] ユーザー入力をバリデーション（型チェック、長さ制限、許可文字）
- [ ] 機密情報をハードコードしていない（環境変数使用）
- [ ] SQLクエリをパラメータ化（SQLインジェクション対策）
- [ ] HTMLエスケープ実施（XSS対策）
- [ ] 認証・認可チェック実施
- [ ] HTTPS通信を強制
- [ ] ログに機密情報を出力していない

### YAMLテンプレート（セキュリティチェック結果）

```yaml
security_check:
  status: No Issues / Minor Concerns / Major Concerns / Critical Issues
  findings:
    - issue: SQLインジェクション脆弱性
      severity: Critical Issues
      location: src/db/queries.py:42
      recommendation: パラメータ化クエリを使用
    - issue: 機密情報のハードコード
      severity: Critical Issues
      location: src/config.py:10
      recommendation: 環境変数に移行
  compliant_items:
    - item: 入力バリデーション
      status: Pass
    - item: HTTPS通信
      status: Pass
```

### 参照

- [`agents/developer.md`](../agents/developer.md) - Phase 7品質基準でのセキュリティチェック
- [`agents/code_reviewer.md`](../agents/code_reviewer.md) - セキュリティレビュー項目

---

## 2. パフォーマンスチェック項目

### 懸念箇所

以下のパフォーマンスボトルネックを特定し、改善します：

| 項目 | 説明 | 改善方法 |
|------|------|---------|
| N+1クエリ | ループ内でのクエリ実行 | `join`、`prefetch_related`を使用 |
| 不要なループ | 非効率なデータ処理 | リスト内包表記、ジェネレータ式 |
| 大量メモリ使用 | 一度に全データをロード | ストリーミング、ページング |
| キャッシング機会の見落とし | 同じ計算を繰り返す | メモ化、Redisキャッシュ |

### ✅ Good Example

```python
from typing import List
from sqlalchemy.orm import Session, joinedload

def get_users_with_posts(db: Session) -> List[User]:
    """ユーザーと投稿を一度に取得（N+1クエリ対策）"""
    # ✅ joinedloadでN+1クエリを回避
    return db.query(User).options(joinedload(User.posts)).all()

def calculate_total_price(items: List[Item]) -> Decimal:
    """商品リストの合計金額を計算"""
    # ✅ リスト内包表記で効率的に計算
    return sum(item.price * item.quantity for item in items)

def process_large_file(file_path: str):
    """大きなファイルをストリーミング処理"""
    # ✅ ストリーミングでメモリ効率的に処理
    with open(file_path, 'r') as f:
        for line in f:
            process_line(line)

from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_calculation(n: int) -> int:
    """計算結果をキャッシュ"""
    # ✅ lru_cacheでメモ化
    return sum(i ** 2 for i in range(n))
```

### ❌ Bad Example

```python
def get_users_with_posts(db):
    # ❌ N+1クエリ問題
    users = db.query(User).all()
    for user in users:
        user.posts = db.query(Post).filter(Post.user_id == user.id).all()
    return users

def calculate_total_price(items):
    # ❌ 非効率なループ
    total = 0
    for item in items:
        total += item.price * item.quantity
    return total

def process_large_file(file_path):
    # ❌ 全データをメモリにロード
    with open(file_path, 'r') as f:
        all_lines = f.readlines()  # 大量メモリ使用
        for line in all_lines:
            process_line(line)

def expensive_calculation(n):
    # ❌ キャッシングなし（毎回計算）
    return sum(i ** 2 for i in range(n))
```

### チェックリスト

- [ ] N+1クエリを回避（`join`、`prefetch_related`使用）
- [ ] 不要なループを削減（リスト内包表記、ジェネレータ式）
- [ ] 大量データをストリーミング処理
- [ ] 計算結果をキャッシュ（`lru_cache`、Redis）
- [ ] データベースインデックスを適切に設定
- [ ] 不要なデータ取得を避ける（`select_related`、必要な列のみ）

### YAMLテンプレート（パフォーマンスチェック結果）

```yaml
performance_check:
  findings:
    - issue: N+1クエリ問題
      location: src/api/routes/users.py:25
      impact: High
      recommendation: joinedloadを使用
    - issue: 全データメモリロード
      location: src/utils/file_processor.py:10
      impact: Medium
      recommendation: ストリーミング処理に変更
  optimizations:
    - optimization: lru_cache追加
      location: src/utils/calculations.py:5
      benefit: 計算時間を90%削減
```

### 参照

- [`agents/code_reviewer.md`](../agents/code_reviewer.md) - パフォーマンスレビュー項目

---

## 3. エラーハンドリング

### 異常終了条件（ユーザーエスカレーション）

以下の条件でユーザーエスカレーションを実施します：

```yaml
escalation_conditions:
  - condition: 修正ループ回数が3回超過
    trigger: code-reviewerのループ制御
  - condition: セキュリティ懸念がCritical Issuesのまま
    trigger: セキュリティチェック
  - condition: 総合評価がNeeds Major Refactoringのまま
    trigger: 品質ゲート
```

### 対応フロー

```
1. ユーザーに現在の状況を提示
   ↓
2. 推奨アクションを提示
   - 設計見直し
   - Issue分割検討
   - 専門家レビュー依頼
   ↓
3. ユーザー判断を仰ぐ
```

### ✅ Good Example（エスカレーション）

```markdown
## ユーザーエスカレーション

修正ループが3回を超えましたが、以下のCritical Issuesが未解決です。

### 未解決のCritical Issues

1. **セキュリティ**: SQLインジェクション脆弱性が残存
   - 場所: `src/db/queries.py:42`
   - 詳細: ユーザー入力を直接SQLクエリに埋め込んでいる

2. **DRY原則**: 認証ロジックの重複が完全に解消されていない
   - 場所: `src/auth/authenticator.py:10`, `src/api/middleware.py:25`
   - 詳細: 同じ認証ロジックが2箇所に存在

### 推奨アクション

1. **設計見直し**: 認証機能を独立したサービスクラスに分離
   - `src/services/auth_service.py` を新規作成
   - DRY原則を遵守した設計に変更

2. **Issue分割**: セキュリティ対策を別Issueとして分離
   - セキュリティ専門家によるレビューを依頼
   - SQLインジェクション対策を優先Issue化

3. **専門家レビュー**: セキュリティエンジニアによるレビュー依頼

ユーザー判断をお願いします。
```

### チェックリスト

- [ ] 修正ループ回数をカウント
- [ ] 3回超過時にユーザーエスカレーション
- [ ] Critical Issuesが未解決の場合はエスカレーション
- [ ] 推奨アクションを具体的に提示
- [ ] ユーザー判断を明示的に仰ぐ

### YAMLテンプレート（エスカレーション）

```yaml
escalation:
  trigger: loop_count_exceeded / critical_issues_unresolved / major_refactoring_needed
  loop_count: 4
  unresolved_issues:
    - issue: SQLインジェクション脆弱性
      severity: Critical Issues
      location: src/db/queries.py:42
  recommended_actions:
    - action: 設計見直し
      details: 認証機能を独立したサービスクラスに分離
    - action: Issue分割
      details: セキュリティ対策を別Issueとして分離
```

### 参照

- [`agents/developer.md`](../agents/developer.md) - Phase 6での修正ループとエスカレーション

---

## 4. ドキュメント記述の原則

### コメント記述

コードのコメントは、**Why（なぜ）**を説明し、**What（何を）**や**How（どのように）**は避けます。

#### ✅ Accept: Why（なぜ）を説明

```python
# データベースのロック競合を回避するため、リトライ処理を実装
for attempt in range(3):
    try:
        update_record(db, user_id, data)
        break
    except LockError:
        time.sleep(0.1)

# パフォーマンス向上のため、キャッシュを使用
# 平均レスポンスタイムが500ms → 50msに改善
@lru_cache(maxsize=128)
def get_user_settings(user_id: int) -> UserSettings:
    return db.query(UserSettings).filter_by(user_id=user_id).first()

# セキュリティ要件により、パスワードは必ず12文字以上
# NIST SP 800-63B に準拠
MIN_PASSWORD_LENGTH = 12
```

#### ❌ Deny: What（何を）を説明

```python
# レコードを更新する（コードを見れば明らか）
update_record(db, user_id, data)

# ユーザー設定を取得する（関数名で明らか）
def get_user_settings(user_id: int) -> UserSettings:
    return db.query(UserSettings).filter_by(user_id=user_id).first()

# 最小パスワード長を12に設定（定数名で明らか）
MIN_PASSWORD_LENGTH = 12
```

#### ❌ Deny: 過度なコメント

```python
# ユーザーIDを取得
user_id = request.user_id

# データベースセッションを取得
db = get_db_session()

# ユーザー情報を取得
user = db.query(User).filter_by(id=user_id).first()

# ユーザー名を取得
username = user.username

# レスポンスを返す
return {"username": username}

# すべて自明なコメント（不要）
```

### アーキテクチャドキュメント

重要な設計判断や複雑な実装には、以下のドキュメントを検討します：

#### アーキテクチャ図・シーケンス図

```markdown
## 認証フロー

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Auth Service
    participant Database

    Client->>API: POST /login
    API->>Auth Service: authenticate(username, password)
    Auth Service->>Database: get_user_by_username()
    Database-->>Auth Service: User
    Auth Service->>Auth Service: verify_password()
    Auth Service-->>API: AuthResult
    API-->>Client: JWT Token
\```
\```

#### APIドキュメントに使用例を含める

```markdown
## POST /api/auth/login

ユーザー認証を行い、JWT トークンを発行します。

### Request

\```json
{
  "username": "testuser",
  "password": "password123"
}
\```

### Response (成功)

\```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
\```

### Response (失敗)

\```json
{
  "error": "invalid_credentials",
  "message": "ユーザー名またはパスワードが正しくありません"
}
\```
```

#### READMEへの変更内容反映

```markdown
## Changes in v2.0.0

### 新機能

- ユーザー認証機能を追加
  - JWT トークンベース認証
  - bcryptによるパスワードハッシュ化
  - Redisセッション管理

### セットアップ

1. 環境変数を設定

\```bash
export SECRET_KEY="your-secret-key"
export REDIS_URL="redis://localhost:6379"
\```

2. データベースマイグレーション実行

\```bash
alembic upgrade head
\```
```

### チェックリスト

- [ ] コメントは「Why（なぜ）」を説明
- [ ] 自明なコメントを避けている
- [ ] 複雑なロジックにはシーケンス図を検討
- [ ] APIドキュメントに使用例を含める
- [ ] READMEに変更内容を反映

### 参照

- [`agents/document_writer.md`](../agents/document_writer.md) - ドキュメント作成ガイドライン

---

## まとめ

Security and Best Practicesでは、以下の4つの主要な領域をカバーしています：

1. **セキュリティチェック項目**: 入力バリデーション、機密情報管理、SQLインジェクション対策、XSS対策
2. **パフォーマンスチェック項目**: N+1クエリ回避、メモリ効率、キャッシング
3. **エラーハンドリング**: ユーザーエスカレーション条件、対応フロー
4. **ドキュメント記述の原則**: Why（なぜ）を説明、アーキテクチャドキュメント

これらのベストプラクティスに従うことで、セキュアで高性能、かつ保守性の高いコードが実現されます。
