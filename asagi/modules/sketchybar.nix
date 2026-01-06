{ config, pkgs, ... }:

{
  # Deploy sketchybar configuration files
  home.file.".config/sketchybar/sketchybarrc" = {
    source = ../configs/sketchybar/sketchybarrc;
    executable = true;
  };

  home.file.".config/sketchybar/colors.sh" = {
    source = ../configs/sketchybar/colors.sh;
    executable = true;
  };

  # Deploy plugins individually with executable permission
  home.file.".config/sketchybar/plugins/apple.sh" = {
    source = ../configs/sketchybar/plugins/apple.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/battery.sh" = {
    source = ../configs/sketchybar/plugins/battery.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/clock.sh" = {
    source = ../configs/sketchybar/plugins/clock.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/cpu.sh" = {
    source = ../configs/sketchybar/plugins/cpu.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/front_app.sh" = {
    source = ../configs/sketchybar/plugins/front_app.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/network.sh" = {
    source = ../configs/sketchybar/plugins/network.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/spaces.sh" = {
    source = ../configs/sketchybar/plugins/spaces.sh;
    executable = true;
  };

  home.file.".config/sketchybar/plugins/volume.sh" = {
    source = ../configs/sketchybar/plugins/volume.sh;
    executable = true;
  };

  # Activation script to reload SketchyBar
  home.activation.reloadSketchyBar = config.lib.dag.entryAfter ["writeBoundary"] ''
    if pgrep -x "sketchybar" > /dev/null; then
      $DRY_RUN_CMD /opt/homebrew/bin/brew services restart sketchybar
    fi
  '';
}
