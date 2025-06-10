return {
  "folke/tokyonight.nvim",
  config = function()
    require("tokyonight").setup({
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
      },
      on_colors = function(colors)
        colors.hint = colors.orange
        colors.error = "#d05050"
      end,
    })
    vim.cmd[[colorscheme tokyonight]]
  end
}
