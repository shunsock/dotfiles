local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP関数マッピング
map('n', 'K',  vim.lsp.buf.hover, opts)
map('n', 'Ffm', vim.lsp.buf.format, opts)
map('n', 'Frf', vim.lsp.buf.references, opts)
map('n', 'Fdf', vim.lsp.buf.definition, opts)
map('n', 'Fdc', vim.lsp.buf.declaration, opts)
map('n', 'Fim', vim.lsp.buf.implementation, opts)
map('n', 'Fty', vim.lsp.buf.type_definition, opts)
map('n', 'Fre', vim.lsp.buf.rename, opts)
map('n', 'Fact', vim.lsp.buf.code_action, opts)
map('n', 'Fe', vim.diagnostic.open_float, opts)
map('n', 'F[', vim.diagnostic.goto_next, opts)
map('n', 'F]', vim.diagnostic.goto_prev, opts)

