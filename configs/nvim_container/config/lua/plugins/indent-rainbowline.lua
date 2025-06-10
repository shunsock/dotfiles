return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = function(_, opts)
    return require("indent-rainbowline").make_opts(opts, {
      color_transparency = 0.3,
      colors = {
        0xf38ba8, -- red
        0xf9e2af, -- yellow
        0xa6e3a1, -- green
        0x94e2d5, -- teal
        0x89b4fa, -- blue
        0xcba6f7, -- purple
      },
    })
  end,
  dependencies = {
    "TheGLander/indent-rainbowline.nvim",
  },
}
