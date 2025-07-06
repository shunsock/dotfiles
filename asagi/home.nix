{ config, pkgs, lib, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  home.activation.cleanOldAquaSKK = lib.hm.dag.entryBefore ["writeBoundary"] ''
  rm -f "${config.home.homeDirectory}/Library/Application Support/AquaSKK/"*".hm-backup"
'';

  imports = [
    ./modules/wezterm.nix
    ./modules/zsh.nix
    ./modules/skk.nix
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
  ];
}
