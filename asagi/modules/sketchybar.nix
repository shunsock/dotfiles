{ config, pkgs, ... }:

{
  # Deploy sketchybar configuration files
  home.file.".config/sketchybar" = {
    source = ../configs/sketchybar;
    recursive = true;
  };

  # Make scripts executable after deployment
  home.activation.makeSketchyBarExecutable = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    chmod +x "$HOME/.config/sketchybar/sketchybarrc"
    chmod +x "$HOME/.config/sketchybar/plugins/"*.sh
  '';
}
