{ config, pkgs, pkgsUnstable, lib, ... }:

{
  imports = [
    ./modules/claude.nix
    ./modules/firefox.nix
    ./modules/gemini.nix
    ./modules/skk.nix
    ./modules/wezterm.nix
    ./modules/zsh.nix
  ];

  # ユーザー情報
  home.username      = "shunsock";
  home.homeDirectory = lib.mkForce "/Users/shunsock";
  home.stateVersion  = "23.11";

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages = with pkgs; [
    dotnet-sdk_10
    gh
    git
    go-task
    hackgen-nf-font
    hyperfine
    mise
    rustup
    tree
    nixfmt-rfc-style
  ] ++ [
    pkgsUnstable.claude-code
    pkgsUnstable.gemini-cli
  ];
}
