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
  require("plugins.catppuccin"),
  require("plugins.indent-blankline"),
  require("plugins.lualine"),
  require("plugins.nvim-cursorline"),
  require("plugins.nvim-tree"),
  require("plugins.tree-sitter"),
})

