{ config, pkgs, ... }:

{
  home.file."Library/Application Support/AquaSKK" = {
    source = ../config/skk;
    recursive = true;
  };
}
