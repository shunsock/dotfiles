local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP関数マッピング
map('n', 'K',  vim.lsp.buf.hover, opts)
map('n', 'gf', vim.lsp.buf.format, opts)
map('n', 'gr', vim.lsp.buf.references, opts)
map('n', 'gd', vim.lsp.buf.definition, opts)
map('n', 'gD', vim.lsp.buf.declaration, opts)
map('n', 'gi', vim.lsp.buf.implementation, opts)
map('n', 'gt', vim.lsp.buf.type_definition, opts)
map('n', 'gn', vim.lsp.buf.rename, opts)
map('n', 'ga', vim.lsp.buf.code_action, opts)
map('n', 'ge', vim.diagnostic.open_float, opts)
map('n', 'g]', vim.diagnostic.goto_next, opts)
map('n', 'g[', vim.diagnostic.goto_prev, opts)

