{ config, pkgs, ... }:

{
  home.file.".config/zsh".source = ../configs/zsh;
  home.file.".config/zsh".recursive = true;

  home.packages = with pkgs; [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    initContent = ''
      unalias -m '*' # 🗑️👋 trash auto added aliases

      setopt extendedglob
      for f in ${config.xdg.configHome}/zsh/**/*.zsh; do
        source "$f"
      done
    '';
  };
}
