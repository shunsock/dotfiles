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
    ./modules/firefox.nix
    ./modules/gemini.nix
    ./modules/skk.nix
    ./modules/wezterm.nix
    ./modules/zsh.nix
  ];

  # ユーザー情報
  home.username = "shunsock";
  home.homeDirectory = lib.mkForce "/Users/shunsock";
  home.stateVersion = "23.11";

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages =
    with pkgs;
    [
      bun
      dotnet-sdk_10
      fzf
      gh
      ghq
      git
      go-task
      hackgen-nf-font
      hyperfine
      mise
      nixfmt-rfc-style
      npins
      rustup
      tree
      wthrr
      yazi
      zoxide
    ]
    ++ [
      pkgsUnstable.claude-code
      pkgsUnstable.google-cloud-sdk
      pkgsUnstable.gemini-cli
    ];
}
