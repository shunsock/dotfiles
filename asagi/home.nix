{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/wezterm.nix
    ./modules/zsh.nix
    ./modules/skk.nix
  ];

  # ユーザー情報
  home.username      = "shunsock";
  home.homeDirectory = lib.mkForce "/Users/shunsock";
  home.stateVersion  = "23.11";

  home.file."Library/Application Support/AquaSKK/skk-jisyo.utf8" = {
    source = ../configs/skk/skk-jisyo.utf8;
    force  = true;
  };

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
  ];
}
