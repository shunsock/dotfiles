{
  config,
  pkgs,
  ...
}:

let
  mod = "Mod4";
in
{
  xdg.configFile."sway/config".text = ''
    # Include NixOS XDG portal configuration
    include /etc/sway/config.d/*

    # Modifier key (Super/CapsLock via keyd remap)
    set $mod ${mod}

    # Terminal
    set $term wezterm

    # Application launcher
    set $menu wmenu-run

    # Natural scrolling
    input "type:pointer" {
      natural_scroll enabled
    }
    input "type:touchpad" {
      natural_scroll enabled
      tap enabled
    }

    # Disable window title bars and borders
    default_border none
    default_floating_border none

    # Disable default swaybar (Noctalia provides panel)
    bar {
      mode invisible
    }

    # Key bindings
    bindsym $mod+Return exec $term
    bindsym $mod+d exec $menu
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+e exec swaymsg exit
    bindsym $mod+Shift+c reload
    bindsym $mod+l exec swaylock

    # Volume (Fn+F1/F2/F3)
    bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

    # Brightness (Fn+F5/F6)
    bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
    bindsym XF86MonBrightnessUp exec brightnessctl set +5%

    # Screenshot
    bindsym Print exec grim ~/Pictures/Screenshots/screenshot-$(date +%s).png
    bindsym Shift+Print exec grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%s).png
    bindsym $mod+Shift+s exec grim -g "$(slurp)" - | wl-copy

    # Focus
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # Move focused window
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # Layout
    bindsym $mod+h splith
    bindsym $mod+v splitv
    bindsym $mod+f fullscreen toggle
    bindsym $mod+Shift+space floating toggle
    bindsym $mod+space focus mode_toggle

    # Workspace cycling (Super+Tab / Super+Shift+Tab)
    bindsym $mod+Tab workspace next
    bindsym $mod+Shift+Tab workspace prev

    # Workspaces (Alt+N to switch, Super+Shift+N to move)
    bindsym Mod1+1 workspace number 1
    bindsym Mod1+2 workspace number 2
    bindsym Mod1+3 workspace number 3
    bindsym Mod1+4 workspace number 4
    bindsym Mod1+5 workspace number 5
    bindsym Mod1+6 workspace number 6
    bindsym Mod1+7 workspace number 7
    bindsym Mod1+8 workspace number 8
    bindsym Mod1+9 workspace number 9

    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9

    # Resize mode
    mode "resize" {
      bindsym Left resize shrink width 10 px
      bindsym Down resize grow height 10 px
      bindsym Up resize shrink height 10 px
      bindsym Right resize grow width 10 px

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    # Window assignment
    assign [app_id="org.wezfurlong.wezterm"] workspace number 1
    assign [app_id="firefox"] workspace number 2

    # Autostart
    exec fcitx5 -r
    exec wezterm
    exec firefox

    # Polkit authentication agent
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
  '';
}
