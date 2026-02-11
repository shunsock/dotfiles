{ config, pkgs, ... }:

{
  home.file.".claude" = {
    source = ../configs/claude;
    recursive = true;
  };
}
