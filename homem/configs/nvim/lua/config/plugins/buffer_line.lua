vim.opt.termguicolors = true

require'bufferline'.setup({
  options = {
    color_icons = true,
    max_name_length = 18,
    max_prefix_length = 15,
    separator_style = 'thin',
    show_buffer_close_icons = false,
    show_close_icon = false,
    tab_size = 22,
    truncate_names = true,
    indicator = {
        icon = '',
        style = 'icon',
    },
    {'|',''}
  },
  highlights = {
    background = {
      fg = '#dddddd',
      bg = '#323232',
    },
    buffer_selected = {
      fg = '#fafafa',
      bg = '#7851A9',
    },
    buffer_visible = {
      fg = '#dddddd',
      bg = '#323232',
    },
    fill = {
      fg = '#dddddd',
      bg = '#323232'
    },
  },
})


-- 現在のバッファより右にあるすべてのバッファを閉じる関数
function CloseRightBuffers()
  local current = vim.fn.bufnr('%')  -- 現在のバッファ番号を取得
  local nvim_tree_bufnr = vim.fn.bufnr('NvimTree')  -- nvim-tree のバッファ番号を取得
  local buffers = vim.fn.getbufinfo({buflisted = 1})  -- リストに表示されるすべてのバッファを取得
  for _, buffer in ipairs(buffers) do
    if buffer.bufnr > current and buffer.bufnr ~= nvim_tree_bufnr then
      vim.cmd('bdelete ' .. buffer.bufnr)  -- nvim-tree のバッファ以外を削除
    end
  end
end

-- 現在のバッファより左にあるすべてのバッファを閉じる関数
function CloseLeftBuffers()
  local current = vim.fn.bufnr('%')  -- 現在のバッファ番号を取得
  local nvim_tree_bufnr = vim.fn.bufnr('NvimTree')  -- nvim-tree のバッファ番号を取得
  local buffers = vim.fn.getbufinfo({buflisted = 1})  -- リストに表示されるすべてのバッファを取得
  for _, buffer in ipairs(buffers) do
    if buffer.bufnr < current and buffer.bufnr ~= nvim_tree_bufnr then
      vim.cmd('bdelete ' .. buffer.bufnr)  -- nvim-tree のバッファ以外を削除
    end
  end
end


vim.api.nvim_set_keymap('n', '<C-]>', ':lua CloseRightBuffers()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-[>', ':lua CloseLeftBuffers()<CR>', { noremap = true, silent = true })
