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

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages = with pkgs; [
    claude-code
    dotnet_sdk-10
    firefox
    gh
    git
    go-task
    hackgen-nf-font
    hyperfine
    rustup
    tree
  ];
}
