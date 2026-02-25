{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:

{
  imports = [
    ./modules/claude.nix
    ./modules/sway.nix
    ./modules/neovim.nix
    ./modules/skk.nix
    ./modules/wezterm.nix
    ./modules/zsh.nix
  ];

  # ユーザー情報
  home.username = "shunsock";
  home.homeDirectory = "/home/shunsock";
  home.stateVersion = "25.05";

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages =
    with pkgs;
    [
      fastfetch
      gh
      go-task
      tree
    ]
    ++ [
      pkgsUnstable.claude-code
    ];
}
