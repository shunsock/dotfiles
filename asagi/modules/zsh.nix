{ config, pkgs, ... }:

{
  # zsh 設定ファイルを再帰的に配置
  home.file.".config/zsh".source = ../configs/zsh;
  home.file.".config/zsh".recursive = true;

  # Zsh関連パッケージ
  home.packages = with pkgs; [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  # Zsh と Oh My Zsh の設定
  programs.zsh = {
    enable = true;

    # Oh My Zsh を有効化しテーマを設定
    "oh-my-zsh" = {
      enable = true;
      theme = "kennethreitz";
      plugins = [ ];
    };

    # ~/.config/zsh 以下を再帰的に source
    initContent = ''
      setopt extendedglob
      for f in $HOME/.config/zsh/**/*.zsh; do
        source "$f"
      done

      # zsh-autosuggestions を最後に読み込み
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };
}
