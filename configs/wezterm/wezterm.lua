local wezterm = require 'wezterm'

local config = {}

-- Font settings
config.font = wezterm.font("HackGen35 Console NF", {
  weight = "Regular",
  stretch = "Normal",
  style = "Normal"
})

config.font_size = 24.0
config.line_height = 1.4

-- Color scheme and opacity
config.color_scheme = 'Tokyo Night Storm (Gogh)'
config.window_background_opacity = 1.0

-- Tab bar settings
config.use_fancy_tab_bar = true

-- Border settings
local border_color = '#783aa1'
config.window_frame = {
  border_left_width = '1.0cell',
  border_right_width = '1.0cell',
  border_bottom_height = '0.5cell',
  border_top_height = '0.5cell',
  border_left_color = border_color,
  border_right_color = border_color,
  border_bottom_color = border_color,
  border_top_color = border_color,
  font_size = 16.0,
}

-- Return the final configuration
return config

