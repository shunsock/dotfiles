---
name: code_inspect__security
description: >-
  code_inspect のセキュリティチェックサブスキル。機密情報のハードコード、injection、
  unsafe deserialization、access control の欠落、安全でないデフォルト設定などを評価する。
  親スキル code_inspect から呼び出される。直接呼び出さないこと。
tools: Read, Bash
---

## 観点の定義

変更コードに、攻撃者が悪用可能なセキュリティ脆弱性が含まれていないかを評価する。
セキュリティ問題はバグと違い、修正されるまで攻撃面として残り続けるため、
原則として must で指摘する。

## 評価手順

### Step 1: 機密情報のハードコード

- API キー・パスワード・トークン・接続文字列がソースコードに埋め込まれていないか
- 秘密鍵・証明書がコミット対象ファイルに含まれていないか
- 環境変数や secret manager からの取得に置き換えられているか

### Step 2: Injection 脆弱性

- SQL injection: ユーザー入力を文字列連結でクエリに埋め込んでいないか (parameterized query を使うべき)
- Command injection: ユーザー入力を `os.system` / `subprocess.shell=True` / バッククォートで実行していないか
- XSS: ユーザー入力をエスケープせず HTML / JSON に埋め込んでいないか
- Path traversal: ユーザー入力をサニタイズせずファイルパスに使っていないか
- LDAP / NoSQL / Template injection の可能性

### Step 3: Unsafe Deserialization

- `pickle.loads`, `eval`, `exec`, `yaml.load` (without SafeLoader), `Marshal.load` などに信頼できない入力を渡していないか
- JSON 以外の形式を外部入力として受け取る場合、安全な loader を使っているか

### Step 4: Access Control の欠落

- 認証が必要なエンドポイント・関数に認可チェックがあるか
- リソース所有者の検証 (IDOR 対策) が行われているか
- 管理者権限が必要な操作にロール検証があるか

### Step 5: 安全でないデフォルト

- HTTP の代わりに HTTPS を使っているか
- TLS 検証が無効化されていないか (`verify=False`, `InsecureRequestWarning` 等)
- 古い暗号化アルゴリズム (MD5, SHA1, DES) を使っていないか
- CORS が過度に緩く設定されていないか (`Access-Control-Allow-Origin: *`)

### Step 6: 機密情報の漏出

- ログ出力に秘密情報 (パスワード、トークン、PII) が含まれていないか
- エラーメッセージが内部実装の詳細 (スタックトレース、SQL クエリ) を晒していないか
- デバッグ情報が本番環境で露出していないか

### 判定基準

- 上記いずれの脆弱性も発見されたら **原則 must**
- 攻撃面が極めて限定的 (内部 CLI ツール等) で実害が小さいケースのみ should
- セキュリティに関わる nit は基本的に存在しない

## 出力契約

`.claude/skills/code_inspect/template/inspect_output.md` の規約に従う。
観点名は `security`。
