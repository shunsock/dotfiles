-- disable netrw
-- conflicts with nvim-tree
vim.api.nvim_set_var('loaded_netrw', 1)
vim.api.nvim_set_var('loaded_netrwPlugin', 1)

-- nvim-tree
require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  view = {
    width = '25%',
    side = 'right',
    signcolumn = 'no',
  },
  renderer = {
    highlight_git = true,
    highlight_opened_files = 'name',
    group_empty = true,
    icons = {
      glyphs = {
        git = {
          unstaged = '!', renamed = '»', untracked = '?', deleted = '✘',
          staged = '✓', unmerged = '', ignored = '◌',
        },
      },
    },
  },
  actions = {
    expand_all = {
      max_folder_discovery = 100,
      exclude = { '.git', 'target', 'build' },
    },
  },
  filters = {
    dotfiles = true,
  },
})


-- start neovim with open nvim-tree
require("nvim-tree.api").tree.toggle(false, true)