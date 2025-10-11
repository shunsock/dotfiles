local opts = { silent = true, expr = true }

-- Copilotのキーマップ
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', opts)