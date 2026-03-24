{ config, pkgs, ... }:

{
  # Common configs shared between nix-darwin and nix-os
  home.file.".config/zsh/common".source = ../../configs/zsh;
  home.file.".config/zsh/common".recursive = true;

  # Platform-specific configs
  home.file.".config/zsh/platform".source = ../configs/zsh;
  home.file.".config/zsh/platform".recursive = true;

  home.packages = with pkgs; [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    "oh-my-zsh" = {
      enable = false;
      theme = "kennethreitz";
      plugins = [ ];
    };

    initContent = ''
      unalias -m '*'
      setopt extendedglob
      for f in ${config.home.homeDirectory}/.config/zsh/**/*.zsh; do
        source "$f"
      done
    '';
  };
}
