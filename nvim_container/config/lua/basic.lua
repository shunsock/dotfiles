-- シンタックスハイライトを有効にします。多くの場合デフォルトで有効ですが、明示的に記述するのも良い習慣です。
vim.cmd('syntax enable')

-- 背景を透過させるため、カラースキームに背景色を設定しないよう指示します。
vim.g.nobackground = 1

-- ファイルが外部で変更された場合に自動で再読み込みします。
vim.opt.autoread = true

-- クリップボードへのヤンクをOSのクリップボードと連携させます。
vim.opt.clipboard = "unnamedplus"

-- 現在のカーソル位置の列をハイライトします。
vim.opt.cursorcolumn = true

-- 現在のカーソル位置の行をハイライトします。
vim.opt.cursorline = true

-- タブをスペースに変換します。
vim.opt.expandtab = true

-- 保存せずにバッファを切り替えられるようにします。
vim.opt.hidden = true

-- 検索時に大文字と小文字を区別しません。
vim.opt.ignorecase = true

-- マウス操作を無効にします。
vim.opt.mouse = ""

-- 行番号を表示します。
vim.opt.number = true

-- インデントの幅をスペース2つに設定します。
vim.opt.shiftwidth = 2

-- 大文字を含む場合は大文字と小文字を区別して検索します。('ignorecase'と併用)
vim.opt.smartcase = true

-- より賢いインデントを行います。
vim.opt.smartindent = true

-- スワップファイルの作成を無効にします。
vim.opt.swapfile = false

-- タブの表示幅をスペース2つに設定します。
vim.opt.tabstop = 2

-- True Colorを有効にし、リッチな色表現を可能にします。
vim.opt.termguicolors = true

-- ターミナルのタイトルを設定します。
vim.opt.title = true

-- 行末を超えてカーソルを1文字だけ移動できるようにします。
vim.opt.virtualedit = "onemore"

-- ビープ音の代わりに画面をフラッシュさせます。
vim.opt.visualbell = true

-- コマンドラインの補完方法を拡張します。
vim.opt.wildmode = "list:longest,full"
