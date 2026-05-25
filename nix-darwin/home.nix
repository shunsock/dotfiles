{
  config,
  pkgs,
  pkgsUnstable,
  pkgsLlmAgents,
  complexity,
  samoyedPkg,
  lib,
  ...
}:

{
  imports = [
    ./modules/bash.nix
    ./modules/claude.nix
    ./modules/antigravity.nix
    ./modules/skk.nix
    ./modules/starship.nix
    ./modules/wezterm.nix
    ./modules/zsh.nix
  ];

  # ユーザー情報
  home.username = "shunsuke.tsuchiya";
  home.homeDirectory = lib.mkForce "/Users/shunsuke.tsuchiya";
  home.stateVersion = "23.11";

  # フォント設定
  fonts.fontconfig.enable = true;

  # インストールするパッケージ
  home.packages =
    with pkgs;
    [
      awscli2
      bun
      ssm-session-manager-plugin
      dotnet-sdk_10
      fzf
      gh
      ghq
      git
      gitleaks
      go-task
      hackgen-nf-font
      hadolint
      hurl
      hyperfine
      nerd-fonts.jetbrains-mono
      nitter
      nixfmt-rfc-style
      npins
      presenterm
      rustup
      tree
      trufflehog
      typos
      wthrr
      yazi
      zoxide
    ]
    ++ [
      complexity
      pkgsLlmAgents.claude-code
      pkgsUnstable.google-cloud-sdk
      pkgsUnstable.gws
      pkgsLlmAgents.antigravity
      samoyedPkg
    ];
}
