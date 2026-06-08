{ config, pkgs, ... }:

{
  # Common configs shared between nix-darwin and nix-os
  home.file.".config/bash/common".source = ../../configs/bash;
  home.file.".config/bash/common".recursive = true;

  # Platform-specific configs
  home.file.".config/bash/platform".source = ../config/bash;
  home.file.".config/bash/platform".recursive = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      unalias -a

      shopt -s globstar
      for f in ${config.xdg.configHome}/bash/**/*.bash; do
        source "$f"
      done
    '';
  };
}
