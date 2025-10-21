-- lazy.nvimのインストール（存在しなければcloneする）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  require("plugins.autosave-nvim"),
  require("plugins.catppuccin"),
  require("plugins.bufferline.setup"),
  require("plugins.copilot.setup"),
  require("plugins.indent-blankline"),
  require("plugins.ionide-vim"),
  require("plugins.lsp.nvim-cmp"),
  require("plugins.lsp.nvim-lspconfig"),
  require("plugins.lualine"),
  require("plugins.nvim-cursorline"),
  require("plugins.nvim-tree"),
  require("plugins.rainbow-delimiters"),
  require("plugins.tree-sitter"),
  require("plugins.vim-oscyank"),
})
