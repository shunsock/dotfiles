-- netrw 無効化（nvim-tree と競合するため）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = "25%",
        side = "right",
        signcolumn = "no",
      },
      renderer = {
        highlight_git = true,
        highlight_opened_files = "name",
        group_empty = true,
        icons = {
          glyphs = {
            git = {
              unstaged = "!",
              renamed = "»",
              untracked = "?",
              deleted = "✘",
              staged = "✓",
              unmerged = "",
              ignored = "◌",
            },
          },
        },
      },
      actions = {
        expand_all = {
          max_folder_discovery = 100,
          exclude = { ".git", "target", "build" },
        },
      },
      filters = {
        dotfiles = true,
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 500,
      },
    })

    -- 起動時にnvim-treeを自動で開く
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local ok, api = pcall(require, "nvim-tree.api")
        if ok then
          api.tree.open()
        end
      end,
    })
  end,
}
