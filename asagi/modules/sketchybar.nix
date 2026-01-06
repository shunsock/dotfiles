{ config, pkgs, ... }:

{
  # Deploy sketchybar configuration files
  home.file.".config/sketchybar" = {
    source = ../configs/sketchybar;
    recursive = true;
  };
}
