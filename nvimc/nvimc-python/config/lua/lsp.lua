-- kakehashi LSP設定（Neovim 0.11 built-in vim.lsp.config）
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- kakehashi: markdown用LSPサーバ + Pythonコードブロックのブリッジ
vim.lsp.config("kakehashi", {
  cmd = { "kakehashi" },
  capabilities = capabilities,
  filetypes = { "markdown", "markdown.mdx" },
  single_file_support = true,
  init_options = {
    autoInstall = true,
    languages = {
      markdown = {
        bridge = {
          python = { enabled = true },
        },
      },
    },
    languageServers = {
      basedpyright = {
        cmd = { "basedpyright-langserver", "--stdio" },
        languages = { "python" },
      },
    },
  },
})

-- basedpyright: Python型チェッカー
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  capabilities = capabilities,
  filetypes = { "python" },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
      },
    },
  },
  single_file_support = true,
})

-- ruff: Pythonリンター/フォーマッター
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  capabilities = capabilities,
  filetypes = { "python" },
  single_file_support = true,
})

vim.lsp.enable({ "kakehashi", "basedpyright", "ruff" })

-- Diagnostic のUI調整
vim.diagnostic.config({
  virtual_text = false,
})
