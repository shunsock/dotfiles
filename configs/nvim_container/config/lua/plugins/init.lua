require("lazy").setup({
  require("plugins.nvim-tree"),
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "vimdoc", "lua", "bash" },
      highlight = { enable = true },
    },
  },
})

