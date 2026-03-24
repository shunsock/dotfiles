return {
  'HiPhish/rainbow-delimiters.nvim',
  config = function()
    local rainbow_delimiters = require 'rainbow-delimiters'

    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
      enable = true,
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
        markdown = rainbow_delimiters.strategy['global'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
        markdown = 'rainbow-delimiters',
      },
      priority = {
        [''] = 110,
        lua = 210,
        markdown = 120,
      },
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    }
    
    -- Markdownファイル用の特別な設定を追加
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"markdown", "markdown.mdx"},
      callback = function()
        vim.cmd([[highlight link markdownLinkDelimiter RainbowDelimiterRed]])
        vim.cmd([[highlight link markdownLinkTextDelimiter RainbowDelimiterYellow]])
        vim.cmd([[highlight link markdownLinkText RainbowDelimiterBlue]])
        vim.cmd([[highlight link markdownUrlDelimiter RainbowDelimiterOrange]])
        vim.cmd([[highlight link markdownUrl RainbowDelimiterGreen]])
      end
    })
  end,
}
