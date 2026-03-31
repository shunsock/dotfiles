-- kakehashi LSP設定（Neovim 0.11 built-in vim.lsp.config）
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("kakehashi", {
  cmd = { "kakehashi" },
  capabilities = capabilities,
  filetypes = { "markdown", "markdown.mdx" },
  single_file_support = true,
  init_options = {
    autoInstall = true,
  },
})

vim.lsp.enable("kakehashi")

-- Diagnostic のUI調整
vim.diagnostic.config({
  virtual_text = false,
})
