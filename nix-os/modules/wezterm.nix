{ config, pkgs, ... }:

{
  # WezTerm configuration
  programs.wezterm = {
    enable = true;
    extraConfig = ''
    local config = {}

    -- General settings
    config.use_ime = true -- Enable IME for Japanese input

    -- OSC52を有効化する
    config.enable_csi_u_key_encoding = true

    -- Font settings
    config.font = wezterm.font("HackGen35 Console NF", {
      weight = "Regular",
      stretch = "Normal",
      style = "Normal"
    })

    config.font_size = 24.0
    config.line_height = 1.6

    -- Color scheme and opacity
    config.color_scheme = 'Tokyo Night Storm (Gogh)'
    config.window_background_opacity = 0.85

    -- Tab bar settings
    config.window_decorations = "NONE"
    config.show_new_tab_button_in_tab_bar = false
    config.show_close_tab_button_in_tabs = false
    config.window_frame = {
      font = wezterm.font("HackGen35 Console NF"),
      font_size = 16.0,
      active_titlebar_bg = "#1a1b26",
      inactive_titlebar_bg = "#1a1b26",
      active_titlebar_fg = "#c0caf5",
      inactive_titlebar_fg = "#565f89",
      border_left_width = 0,
      border_right_width = 0,
      border_top_height = 0,
      border_bottom_height = 0,
    }
    config.colors = {
       tab_bar = {
         background = "#1a1b26",
         active_tab = {
           bg_color = "#24283b",
           fg_color = "#c0caf5",
         },
         inactive_tab = {
           bg_color = "#1a1b26",
           fg_color = "#565f89",
         },
         inactive_tab_hover = {
           bg_color = "#24283b",
           fg_color = "#c0caf5",
         },
         inactive_tab_edge = "none",
       },
    }

    -- Key bindings
    config.keys = {
      -- Clipboard operations (Linux standard)
      {
        key = 'c',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CopyTo 'Clipboard',
      },
      {
        key = 'v',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.PasteFrom 'Clipboard',
      },
      -- Window management
      {
        key = 'f',
        mods = 'CTRL',
        action = wezterm.action.ToggleFullScreen
      },
      {
        key = 'y',
        mods = 'CTRL',
        action = wezterm.action.ActivateCopyMode
      },
      {
        key = 'i',
        mods = 'CTRL',
        action = wezterm.action.SplitPane {
          direction = 'Down',
          size = { Percent = 20 },
        },
      },
      -- Pane navigation
      {
        key = 'H',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Left',
      },
      {
        key = 'J',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Down',
      },
      {
        key = 'K',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Up',
      },
      {
        key = 'L',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection 'Right',
      },
    }

    -- Return the final configuration
    return config
    '';
  };
}
