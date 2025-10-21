-- バッファライン用の関数をグローバルに定義

-- 現在のバッファより右にあるすべてのバッファを閉じる関数
_G.CloseRightBuffers = function()
  local current = vim.fn.bufnr('%')
  local nvim_tree_bufnr = vim.fn.bufnr('NvimTree')
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  for _, buffer in ipairs(buffers) do
    if buffer.bufnr > current and buffer.bufnr ~= nvim_tree_bufnr then
      vim.cmd('bdelete ' .. buffer.bufnr)
    end
  end
end

-- 現在のバッファより左にあるすべてのバッファを閉じる関数
_G.CloseLeftBuffers = function()
  local current = vim.fn.bufnr('%')
  local nvim_tree_bufnr = vim.fn.bufnr('NvimTree')
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  for _, buffer in ipairs(buffers) do
    if buffer.bufnr < current and buffer.bufnr ~= nvim_tree_bufnr then
      vim.cmd('bdelete ' .. buffer.bufnr)
    end
  end
end