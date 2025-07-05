{ config, pkgs, ... }:

{
  imports = [
    ./modules/wezterm.nix
  ];

  # ユーザー情報
  home.username      = "shunsock";
  home.homeDirectory = pkgs.lib.mkForce "/Users/shunsock";
  home.stateVersion  = "23.11";

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages = with pkgs; [
    claude-code
    dotnetCorePackages.dotnet_9.sdk
    gh
    git
    go-task
    hackgen-nf-font
    hyperfine
    rustup
    tree
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  # zsh 設定ファイルを再帰的に配置
  home.file.".config/zsh".source    = ./zsh;
  home.file.".config/zsh".recursive = true;

  # Zsh と Oh My Zsh の設定
  programs.zsh = {
    enable = true;

    # Oh My Zsh を有効化しテーマを設定
    "oh-my-zsh" = {
      enable  = true;
      theme   = "kennethreitz";
      plugins = [];
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