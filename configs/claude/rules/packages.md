# Package Execution Rule

## 原則

パッケージの実行は `nix run nixpkgs#<package>` 経由で行う。

## 手順

1. `nix run nixpkgs#<package>` で実行を試みる
2. nixpkgsに存在しない場合は実行を中止し、ユーザーに報告して代替手段を相談する

## 禁止事項

以下の手段によるパッケージのインストール・実行は一切禁止する：

- `brew install` / `brew` コマンド
- `curl` によるスクリプトダウンロード・実行
- `wget` によるバイナリ取得
- `pip install` / `npm install -g` などのグローバルインストール
- その他 Nix 以外のパッケージマネージャ
