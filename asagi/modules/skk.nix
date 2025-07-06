{ config, pkgs, ... }:

{
  home.file."Library/Application Support/AquaSKK" = {
    source    = ../configs/skk;
    recursive = true;
    backup    = false;
  };
}
