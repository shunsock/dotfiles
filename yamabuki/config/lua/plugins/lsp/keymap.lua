local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP関数マッピング
map('n', 'K',  vim.lsp.buf.hover, opts)
map('n', 'Ff', vim.lsp.buf.format, opts)
map('n', 'Fr', vim.lsp.buf.references, opts)
map('n', 'Fdf', vim.lsp.buf.definition, opts)
map('n', 'Fdc', vim.lsp.buf.declaration, opts)
map('n', 'Fi', vim.lsp.buf.implementation, opts)
map('n', 'Ft', vim.lsp.buf.type_definition, opts)
map('n', 'Fn', vim.lsp.buf.rename, opts)
map('n', 'Fa', vim.lsp.buf.code_action, opts)
map('n', 'Fe', vim.diagnostic.open_float, opts)
map('n', 'F[', vim.diagnostic.goto_next, opts)
map('n', 'F]', vim.diagnostic.goto_prev, opts)

