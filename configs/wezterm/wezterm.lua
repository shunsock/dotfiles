local wezterm = require 'wezterm'

local config = {}

config.font = wezterm.font(
  "Moralerspace Argon HWNF",
  {
    weight="Regular",
    stretch="Normal",
    style="Normal"
  }
)

config.font_size = 24.0
config.line_height = 1.25

config.color_scheme = 'Tokyo Night'

config.window_background_opacity = 0.9
config.window_decorations = 'RESIZE'
config.window_padding = { left = 15, right = 15, top = 0, bottom = 0 }

config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

return config