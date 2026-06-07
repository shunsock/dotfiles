{ config, pkgs, ... }:

{
  home.file.".gemini/antigravity-cli" = {
    source = ../config/antigravity;
    recursive = true;
  };
}
