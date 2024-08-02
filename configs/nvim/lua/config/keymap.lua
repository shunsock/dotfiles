-- Disable search highlighting with ESC ESC
vim.api.nvim_set_keymap("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", { noremap = true, silent = true })

-- set ; as leaderkey
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"