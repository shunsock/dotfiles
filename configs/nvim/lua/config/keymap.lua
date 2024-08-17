local opts = { noremap = true, silent = true }

-- Disable search highlighting with ESC ESC
vim.api.nvim_set_keymap("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", opts)

-- set <Space>hjkl as <C-w>hjkl
vim.api.nvim_set_keymap('n', '<Space>h', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<Space>j', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<Space>k', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<Space>l', '<C-w>l', opts)


-- set K as <Esc>
vim.api.nvim_set_keymap('n', 'K', '<Esc>', opts)
vim.api.nvim_set_keymap('x', 'K', '<Esc>', opts)
vim.api.nvim_set_keymap('i', 'o', '<Esc>', opts)
vim.api.nvim_set_keymap('i', 'K', '<Esc>', opts)

-- set ; as leaderkey
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"
