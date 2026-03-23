{ config, pkgs, ... }:

{
  # Common configs shared between asagi and azuma
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
