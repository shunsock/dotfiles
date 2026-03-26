return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup {
      ensure_installed = {
        "markdown",
        "markdown_inline",
        "fsharp",
      },
      auto_install = true,
    }

    -- 大きなファイルではtreesitter highlightを無効化
    vim.api.nvim_create_autocmd("BufReadPre", {
      callback = function(args)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > max_filesize then
          vim.treesitter.stop(args.buf)
        end
      end,
    })
  end,
}

