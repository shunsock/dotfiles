# LSP Configuration

このディレクトリには Neovim の Language Server Protocol (LSP) 関連の設定ファイルが含まれています。

## ファイル構成

- `keymap.lua` - LSP機能のキーマッピング定義
- `nvim-cmp.lua` - 補完エンジン（nvim-cmp）の設定
- `nvim-lspconfig.lua` - LSPサーバーの設定

## インストール済み言語サーバー

以下の言語サーバーが自動的にインストールされます：

- `lua_ls` - Lua言語サーバー
- `rust_analyzer` - Rust言語サーバー

## キーマッピング

| キー | 機能 |
|------|------|
| `K` | ホバー情報表示 |
| `Ff` | コードフォーマット |
| `Fr` | 参照検索 |
| `Fdf` | 定義へ移動 |
| `Fdc` | 宣言へ移動 |
| `Fi` | 実装へ移動 |
| `Ft` | 型定義へ移動 |
| `Fn` | 名前変更 |
| `Fa` | コードアクション |
| `Fe` | 診断情報表示 |
| `F[` | 次の診断へ移動 |
| `F]` | 前の診断へ移動 |

## 注意事項

- LSPサーバーは Mason を通じて管理されており、`ensure_installed` で指定されたサーバーが自動的にインストールされます。追加のサーバーが必要な場合は `nvim-lspconfig.lua` ファイル内の `ensure_installed` リストに追加してください。