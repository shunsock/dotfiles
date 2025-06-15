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
      -- 最初にmasonをセットアップ
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
        ensure_installed = { "lua_ls", "pyright", "rust_analyzer" }
      })
      
      -- lspconfigの設定
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- 各サーバーの手動設定
      -- lua_ls (Lua言語サーバー)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      
      -- pyright (Python言語サーバー)
      lspconfig.pyright.setup({
        capabilities = capabilities,
      })
      
      -- rust_analyzer (Rust言語サーバー)
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
      })

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = false,
      })

      -- Reference highlighting
      vim.cmd [[
        set updatetime=500
        highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
        highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
        highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
        augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
        augroup END
      ]]
    end,
  },
}
