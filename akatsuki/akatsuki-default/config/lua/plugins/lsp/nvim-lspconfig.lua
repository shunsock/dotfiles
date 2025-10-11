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
        },
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
        PATH = "append",
        pip = {
          install_args = {},
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
      
      -- mason-lspconfigの設定
      require("mason-lspconfig").setup({
        ensure_installed = { "marksman" },
        automatic_installation = true,
      })
      
      -- インストール後に自動的にLSPサーバーを起動させる (APIに合わせて修正)
      -- 古いバージョンの場合は on_server_ready を使用する
      local has_handlers, mlsp = pcall(function()
        local m = require("mason-lspconfig")
        if m.setup_handlers then
          return m
        else
          return nil
        end
      end)
      
      if has_handlers and mlsp then
        mlsp.setup_handlers({
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        })
      end
      
      -- lspconfigの設定
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- 各サーバーの手動設定
      -- marksman (Markdown言語サーバー)
      lspconfig.marksman.setup({
        capabilities = capabilities,
        filetypes = { "markdown", "markdown.mdx" },
        cmd = { "marksman", "server" },
        root_dir = function(fname)
          return lspconfig.util.find_git_ancestor(fname) or lspconfig.util.path.dirname(fname)
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
