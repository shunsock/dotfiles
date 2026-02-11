{ config, pkgs, ... }:

{
  home.file.".config/zsh".source = ../configs/zsh;
  home.file.".config/zsh".recursive = true;

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
