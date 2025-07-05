# Copilot プラグイン設定

GitHub Copilotのプラグイン設定ファイルです。

## 構成ファイル

- `setup.lua`: Copilotの基本設定
- `keymap.lua`: Copilot用のキーマッピング

## キーマップ

| キー | モード | 機能 |
|------|--------|------|
| `<C-J>` | Insert | Copilotの提案を受け入れる |

## 特記事項

- デフォルトのTabキーによる補完は無効化されています（`copilot_no_tab_map = true`）
- すべてのファイルタイプでCopilotが有効になっています
- 提案を受け入れるには挿入モードで`<C-J>`を使用してください