# Package Execution Rule

## 原則

パッケージの実行は Nix 経由で行う。状況に応じて以下の2つの方法を使い分ける。

### 方法1: `nix run nixpkgs#<package>` (アドホック実行)

- nixpkgs に存在するパッケージを一時的に実行する場合に使用
- プロジェクトの flake.nix に依存しない

### 方法2: `nix develop -c <command>` (開発シェル経由)

- プロジェクトに flake.nix が存在し、devShell が定義されている場合に使用
- プロジェクト固有の依存関係やツールチェーンが必要な場合に優先する

## 手順

1. カレントディレクトリまたは祖先に flake.nix があるか確認する
2. flake.nix に devShell/devShells の定義がある場合 → `nix develop -c <command>` を使用
3. devShell がない場合、または nixpkgs のアドホックツールを使う場合 → `nix run nixpkgs#<package>` を使用
4. いずれも失敗した場合は実行を中止し、ユーザーに報告して代替手段を相談する

## 禁止事項

以下の手段によるパッケージのインストール・実行は一切禁止する：

- `brew install` / `brew` コマンド
- `curl` によるスクリプトダウンロード・実行
- `wget` によるバイナリ取得
- `pip install` / `npm install -g` などのグローバルインストール
- その他 Nix 以外のパッケージマネージャ
