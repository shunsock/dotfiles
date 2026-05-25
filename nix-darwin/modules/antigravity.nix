{ config, pkgs, ... }:

{
  home.file.".gemini/antigravity-cli" = {
    source = ../configs/antigravity;
    recursive = true;
  };
}
