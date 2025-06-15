# Neovim 設定ファイル

このディレクトリには Neovim の設定ファイルが含まれています。

## ファイル構成

- `basic.lua`: 基本設定
- `keymap.lua`: キーマップの設定
- `lazy-nvim.lua`: プラグインマネージャーの設定
- `plugins/`: プラグイン固有の設定
  - 各プラグインごとにディレクトリまたはファイルを作成

## キーマップ設定

`keymap.lua` には以下のグローバルなキーマップが設定されています：

- `<Esc><Esc>`: 検索ハイライトをクリア
- `<Space>hjkl`: ウィンドウ間の移動（`<C-w>hjkl` と同等）
- `jj`: インサートモードから抜ける（`<Esc>` と同等）
- `;`: リーダーキー

プラグイン固有のキーマップは各プラグインディレクトリの `keymap.lua` に定義されています：
- `plugins/bufferline/keymap.lua`
- `plugins/lsp/keymap.lua`
- `plugins/copilot/keymap.lua`

## プラグイン設定

プラグイン設定ファイルは以下のパターンに従います：
- `setup.lua`: プラグインの主要設定
- `keymap.lua`: プラグイン固有のキーマップ
- `function.lua`: プラグイン用のカスタム関数

## コーディング規約

- インデント: 2スペース（タブなし）
- 変数宣言には `local` を使用
- キーマップには `vim.api.nvim_set_keymap` または `vim.keymap.set` を使用（`{ noremap = true, silent = true }` 付き）
- 関数と変数名には snake_case を使用
- コメントは日本語で記述