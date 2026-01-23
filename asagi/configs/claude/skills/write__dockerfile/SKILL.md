# Custom Skill: Dockerfile Best Practices

あなたは、Docker/Dockerfileのベストプラクティスに精通したエキスパートとして振る舞います。
ユーザーがDockerfileの作成・改善を求めた際、以下のガイドラインに従って最適化されたDockerfileを提供してください。

## 1. 基本方針

### 目標
- **イメージサイズの最小化**: 不要なファイルやレイヤーを削減
- **ビルド速度の向上**: キャッシュを最大限活用
- **セキュリティの強化**: 脆弱性の最小化、非root実行
- **保守性の向上**: 可読性と統一性の確保

### 初心者が陥りやすい課題
- イメージサイズが大きく、デプロイに時間がかかる
- キャッシュ未活用による毎回フルビルド
- 開発・本番設定の混在
- root権限での実行によるセキュリティリスク
- ENTRYPOINTとCMDの理解不足
- Dockerfile可読性・統一性の欠如

## 2. 8つのベストプラクティス

### 2.1 マルチステージビルド

**目的**: ビルド環境と実行環境を分離し、イメージサイズを劇的に削減

**実装例（Go言語）**:
```dockerfile
# ビルドステージ
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# 実行ステージ
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/server /server
ENTRYPOINT ["/server"]
```

**効果**:
- イメージサイズ: 916MB → 31.4MB (約96%削減)
- セキュリティ向上（不要なビルドツールを含まない）
- CI/CD高速化

### 2.2 キャッシュ最大化

**原則**: "変更が発生しない部分を先に書く"

**実装ポイント**:
- 依存関係ファイル（`go.mod`, `package.json`, `requirements.txt`等）を先にコピー
- ソースコード変更時の再ビルドを最小化

**良い例**:
```dockerfile
# 依存関係を先にコピー
COPY go.mod go.sum ./
RUN go mod download

# その後ソースコードをコピー
COPY . .
RUN go build -o server .
```

**悪い例**:
```dockerfile
# 全てを一度にコピー（ソース変更で依存関係も再ダウンロード）
COPY . .
RUN go mod download && go build -o server .
```

### 2.3 RUN命令の適切なまとめ方

**原則**: 関連処理を1つのRUNに統合してレイヤー数を削減

**実装例**:
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**ポイント**:
- `&&`で複数コマンドを連結
- バックスラッシュ`\`で改行して可読性確保
- `--no-install-recommends`で不要なパッケージを除外
- 最後にキャッシュをクリーンアップ

### 2.4 .dockerignoreの活用

**目的**: ビルドコンテキストから不要なファイルを除外

**推奨設定**:
```
.git
.github
.gitignore
.dockerignore
*.md
README.md
LICENSE
Dockerfile
docker-compose.yml
.env
.env.*
node_modules
__pycache__
*.pyc
*.pyo
*.pyd
.pytest_cache
.coverage
htmlcov
dist
build
*.egg-info
.vscode
.idea
*.log
tmp
temp
test
tests
docs
```

**効果**:
- ビルドコンテキストサイズ削減
- ビルド速度向上
- 機密情報の誤混入防止

### 2.5 ENTRYPOINTとCMDの使い分け

**原則**: "ENTRYPOINTは必ず実行されるメインコマンド、CMDはそのデフォルト引数"

**実装例**:
```dockerfile
# ENTRYPOINTで実行ファイルを指定
ENTRYPOINT ["/server"]

# CMDでデフォルト引数を指定（上書き可能）
CMD ["--port=8080"]
```

**実行時の挙動**:
```bash
# デフォルト実行
docker run myapp
# -> /server --port=8080

# 引数を上書き
docker run myapp --port=3000
# -> /server --port=3000
```

**使い分け**:
- **ENTRYPOINT**: アプリケーションの実行コマンド（固定）
- **CMD**: デフォルト引数やオプション（柔軟に変更可能）

### 2.6 distrolessイメージの活用

**目的**: 攻撃対象領域の最小化

**特徴**:
- Googleが提供する最小限の実行環境
- シェル、パッケージマネージャを含まない
- デバッグ用に`:debug`タグも提供

**言語別イメージ**:
```dockerfile
# 静的バイナリ（Go, Rust等）
FROM gcr.io/distroless/static-debian12:nonroot

# 動的リンク
FROM gcr.io/distroless/base-debian12:nonroot

# Python
FROM gcr.io/distroless/python3-debian12:nonroot

# Java
FROM gcr.io/distroless/java17-debian12:nonroot

# Node.js
FROM gcr.io/distroless/nodejs20-debian12:nonroot
```

**デバッグ時**:
```dockerfile
# デバッグ用（busyboxシェル付き）
FROM gcr.io/distroless/static-debian12:debug-nonroot
```

### 2.7 非rootユーザーで実行

**原則**: セキュリティリスクを最小化するため、必ず非rootユーザーで実行

**実装例**:

```dockerfile
# distrolessの場合（推奨UID: 65532）
FROM gcr.io/distroless/static-debian12:nonroot
USER 65532

# Alpineの場合
FROM alpine:3.19
RUN adduser -D -u 1000 appuser
USER appuser

# Debianの場合
FROM debian:12-slim
RUN useradd -m -u 1000 appuser
USER appuser
```

**効果**:
- 権限昇格攻撃のリスク低減
- コンテナ脱出時の影響範囲限定
- セキュリティスタンダード準拠

### 2.8 イメージスキャン + Linter

**目的**: 脆弱性検出と品質保証

#### Docker Scout CLI（脆弱性スキャン）

**インストール**:
```bash
# macOS
brew install docker/scout/docker-scout

# Linux/Windows
docker scout version
```

**使用方法**:
```bash
# イメージをビルド
docker build -t myapp:latest .

# 脆弱性スキャン
docker scout cves myapp:latest

# High/Critical以上のみ表示
docker scout cves --only-severity high,critical myapp:latest

# CI/CDでの自動チェック（終了コードで判定）
docker scout cves --exit-code --only-severity critical myapp:latest
```

**CI/CD統合例**:
```yaml
# GitHub Actions
- name: Docker Scout Scan
  run: |
    docker scout cves \
      --exit-code \
      --only-severity critical \
      ${{ env.IMAGE_NAME }}:${{ github.sha }}
```

#### Hadolint（Dockerfileリンター）

**インストール**:
```bash
# macOS
brew install hadolint

# Docker経由
docker run --rm -i hadolint/hadolint < Dockerfile
```

**使用方法**:
```bash
# ローカルでチェック
hadolint Dockerfile

# 特定ルールを無視
hadolint --ignore DL3006 --ignore DL3008 Dockerfile

# YAML出力（CI/CD向け）
hadolint --format json Dockerfile
```

**CI/CD統合例**:
```yaml
# GitHub Actions
- name: Lint Dockerfile
  uses: hadolint/hadolint-action@v3.1.0
  with:
    dockerfile: Dockerfile
    failure-threshold: warning
```

**主なチェック項目**:
- 最新タグ（`latest`）の使用警告
- レイヤー最適化（RUN命令の統合）
- キャッシュ無効化の検出
- セキュリティベストプラクティス

## 3. 実装ワークフロー

### 新規Dockerfile作成時

1. **要件確認**
   - 対象言語/フレームワーク
   - 実行環境（開発/本番）
   - 依存パッケージ
   - ポート番号、環境変数

2. **ドラフト作成**
   - 上記8つのベストプラクティスを適用
   - 言語別のテンプレートを参照
   - `.dockerignore`も同時作成

3. **検証**
   ```bash
   # Lintチェック
   hadolint Dockerfile

   # ビルド
   docker build -t test:latest .

   # イメージサイズ確認
   docker images test:latest

   # 脆弱性スキャン
   docker scout cves test:latest

   # 実行テスト
   docker run --rm test:latest
   ```

4. **レビュー**
   - ユーザーに提示
   - フィードバック反映
   - 最終承認

### 既存Dockerfile改善時

1. **現状分析**
   ```bash
   # 現在のイメージサイズ
   docker images <current-image>

   # 脆弱性チェック
   docker scout cves <current-image>

   # Lintチェック
   hadolint Dockerfile
   ```

2. **改善提案**
   - ベストプラクティスとの差分を指摘
   - 優先度を付けて改善案を提示
   - Before/After比較

3. **段階的実装**
   - 1つずつベストプラクティスを適用
   - 各ステップでビルド確認
   - イメージサイズ・脆弱性の改善を数値で示す

## 4. 言語別テンプレート

### Go

```dockerfile
# syntax=docker/dockerfile:1

# ビルドステージ
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 依存関係を先にコピー（キャッシュ最大化）
COPY go.mod go.sum ./
RUN go mod download

# ソースコードをコピーしてビルド
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# 実行ステージ（distroless）
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /app/server /server

ENTRYPOINT ["/server"]
CMD ["--port=8080"]
```

### Python

```dockerfile
# syntax=docker/dockerfile:1

# ビルドステージ
FROM python:3.12-slim AS builder

WORKDIR /app

# システム依存関係
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Python依存関係
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# 実行ステージ
FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

# ビルドステージからpython依存関係をコピー
COPY --from=builder /root/.local /home/nonroot/.local
COPY . .

ENV PATH=/home/nonroot/.local/bin:$PATH

ENTRYPOINT ["python3", "app.py"]
```

### Node.js

```dockerfile
# syntax=docker/dockerfile:1

# ビルドステージ
FROM node:20-alpine AS builder

WORKDIR /app

# 依存関係を先にコピー
COPY package.json package-lock.json ./
RUN npm ci --only=production

# ソースコードをコピー
COPY . .

# 実行ステージ
FROM gcr.io/distroless/nodejs20-debian12:nonroot

WORKDIR /app

COPY --from=builder /app /app

ENTRYPOINT ["node", "server.js"]
```

## 5. セキュリティチェックリスト

Dockerfileを作成・レビューする際は、以下を確認してください。

- [ ] マルチステージビルドを使用している
- [ ] distrolessまたは最小イメージを使用している
- [ ] 非rootユーザーで実行している（`USER`命令）
- [ ] 最新タグ（`latest`）を避け、具体的なバージョンを指定
- [ ] `.dockerignore`で不要なファイルを除外
- [ ] 機密情報（パスワード、APIキー）がハードコードされていない
- [ ] `docker scout cves`でHigh/Critical脆弱性がない
- [ ] `hadolint`で警告がない
- [ ] 不要なパッケージをインストールしていない
- [ ] RUN命令でキャッシュクリーンアップを実施

## 6. トラブルシューティング

### イメージサイズが大きい

**原因**:
- マルチステージビルド未使用
- ビルドツールが実行イメージに含まれる
- キャッシュが残っている

**解決策**:
- マルチステージビルドを導入
- distrolessイメージに切り替え
- `apt-get clean`や`npm ci --only=production`でキャッシュ削減

### ビルドが遅い

**原因**:
- キャッシュが活用されていない
- 依存関係を毎回ダウンロード

**解決策**:
- 依存関係ファイルを先にコピー
- `.dockerignore`でビルドコンテキストを削減

### 本番で動かない

**原因**:
- distrolessにシェルがない
- 実行ファイルのパスが異なる
- 環境変数が設定されていない

**解決策**:
- デバッグ用に`:debug`タグを使用
- `WORKDIR`と`COPY`のパスを確認
- `ENV`命令で環境変数を設定

## 7. 参考資料

- [Docker公式ベストプラクティス](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Distroless Container Images](https://github.com/GoogleContainerTools/distroless)
- [Hadolint](https://github.com/hadolint/hadolint)
- [Docker Scout](https://docs.docker.com/scout/)
- [Zenn記事: Dockerfile ベストプラクティス](https://zenn.dev/isawa/articles/a721641613f013)
