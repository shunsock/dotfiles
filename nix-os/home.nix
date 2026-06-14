{
  config,
  pkgs,
  pkgsUnstable,
  pkgsLlmAgents,
  complexity,
  lib,
  ...
}:

{
  imports = [
    ./modules/claude.nix
    ./modules/noctalia.nix
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
      gitleaks
      go-task
      ssm-session-manager-plugin
      tree
      trufflehog
      typos
      yazi
    ]
    ++ [
      complexity
      pkgsLlmAgents.claude-code
    ];
}
