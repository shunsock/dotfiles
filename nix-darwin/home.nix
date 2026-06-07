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
    ./module/bash.nix
    ./module/claude.nix
    ./module/antigravity.nix
    ./module/skk.nix
    ./module/starship.nix
    ./module/wezterm.nix
    ./module/zsh.nix
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
      pkgsLlmAgents.antigravity-cli
    ];
}
