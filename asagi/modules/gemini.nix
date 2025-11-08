{ config, pkgs, ... }:

{
  home.file.".gemini" = {
    source = ../configs/gemini;
    recursive = true;
  };
}
