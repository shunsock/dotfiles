return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/vim-vsnip' },
    },
    config = function()
      -- masonをセットアップ
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
      
      -- mason-lspconfigの設定
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "marksman" }
      })
      
      -- lspconfigの設定
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- 各サーバーの手動設定
      -- lua_ls (Lua言語サーバー)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      
      -- rust_analyzer (Rust言語サーバー)
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
      })
      
      -- marksman (Markdown言語サーバー)
      lspconfig.marksman.setup({
        capabilities = capabilities,
        filetypes = { "markdown", "markdown.mdx" },
        root_dir = function(fname)
          return lspconfig.util.find_git_ancestor(fname)
        end,
        single_file_support = true,
      })

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  },
}
