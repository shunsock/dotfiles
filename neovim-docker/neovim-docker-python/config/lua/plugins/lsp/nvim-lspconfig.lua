return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/vim-vsnip" },
    },
    config = function()
      -- mason 基本設定
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
        PATH = "append",
        pip = { install_args = {} },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })

      -- mason-lspconfig: インストールと自動有効化
      require("mason-lspconfig").setup({
        ensure_installed = { "marksman" },
        automatic_installation = true,
        automatic_enable = true,
      })

      -- nvim-cmp 連携: capabilities を付与
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- サーバごとの上書き/拡張は vim.lsp.config('<name>', { ... })
      vim.lsp.config("marksman", {
        capabilities = capabilities,
        filetypes = { "markdown", "markdown.mdx" },
        -- marksman は "marksman server" で起動する構成がデフォルト。
        -- PATHに入っていれば cmd の明示は通常不要だが、必要なら以下を残す:
        -- cmd = { "marksman", "server" },
        -- root 検出は lspconfig の既定値で十分。独自にしたい場合だけ指定:
        -- root_dir = require("lspconfig.util").root_pattern(".git", ".marksman.toml"),
        single_file_support = true,
      })

      -- basedpyright サーバ設定
      vim.lsp.config("basedpyright", {
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

      -- ruff サーバ設定
      vim.lsp.config("ruff", {
        capabilities = capabilities,
        filetypes = { "python" },
        init_options = {
          settings = {
            args = {},
          },
        },
        single_file_support = true,
      })

      -- automatic_enable を使わない環境でも確実に有効化できるように明示的に enable
      -- （既に有効なら二重起動はされず安全）
      vim.lsp.enable({ "marksman", "basedpyright", "ruff" })

      -- Diagnostic のUI調整
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  },
}

