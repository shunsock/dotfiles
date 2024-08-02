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

vim.keymap.set('n', 'gr', '<Cmd>BufferLineCyclePrev<CR>', {})
vim.keymap.set('n', 'gt', '<Cmd>BufferLineCycleNext<CR>', {})