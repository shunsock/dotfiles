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
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    "oh-my-zsh" = {
      enable = true;
      theme = "kennethreitz";
      plugins = [ ];
    };

    initContent = ''
      unalias -m '*' # 🗑️👋 trash auto added aliases

      setopt extendedglob
      setopt null_glob
      for f in $ZDOTDIR/**/*.zsh(.N); do
        source "$f"
      done
    '';
  };
}
