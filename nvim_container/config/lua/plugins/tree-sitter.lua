return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      sync_install = false,
      auto_install = true,

      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = {
          "markdown" -- markdownファイルでは追加のVimシンタックスハイライトを有効化
        },
      },
      
      -- markdownパーサーを確実にインストール
      ensure_installed = {
        "markdown",
        "markdown_inline"
      },
    }
    
    -- markdownファイル用の特別な設定
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"markdown", "markdown.mdx"},
      callback = function()
        -- markdownファイルでTree-sitterが正常に動作していることを確認
        vim.cmd("TSEnable highlight")
      end
    })
  end,
}

