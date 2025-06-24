return {
  'stevearc/conform.nvim',
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        markdown = { "prettier" },
        -- fsharp = { "fantomas" },  -- F#フォーマッター（一時的に無効化）
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
      },
      
      -- フォーマッターの設定
      formatters = {
        fantomas = {
          command = "dotnet",
          args = { "fantomas", "--stdin", "--stdout" },
          stdin = true,
        },
      },
      
      -- 保存時にフォーマット
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
    
    -- キーマップ設定
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { desc = "Format file or range (in visual mode)", noremap = true, silent = true })
  end,
}