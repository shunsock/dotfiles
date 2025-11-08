{ config, pkgs, ... }:

{
  home.file.".gemini" = {
    source    = ../configs/claude;
    recursive = true;
  };
}

