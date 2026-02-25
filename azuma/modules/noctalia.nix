{ config, pkgs, ... }:

{
  xdg.configFile."noctalia/colors.json".source = ../configs/noctalia/colors.json;
  xdg.configFile."noctalia/settings.json".source = ../configs/noctalia/settings.json;
}
