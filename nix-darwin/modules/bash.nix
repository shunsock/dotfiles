{ config, pkgs, ... }:

{
  home.file.".config/bash".source = ../configs/bash;
  home.file.".config/bash".recursive = true;

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
