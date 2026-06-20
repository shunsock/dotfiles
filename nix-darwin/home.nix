{
  config,
  pkgs,
  pkgsUnstable,
  pkgsLlmAgents,
  complexity,
  lazynixPkg,
  hisuiPkg,
  username,
  homeDirectory,
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
  home.username = username;
  home.homeDirectory = lib.mkForce homeDirectory;
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
      go-task
      hackgen-nf-font
      hurl
      hyperfine
      nerd-fonts.jetbrains-mono
      nixfmt-rfc-style
      rustup
      tree
      wthrr
      yazi
    ]
    ++ [
      complexity
      lazynixPkg
      hisuiPkg
      pkgsLlmAgents.claude-code
      pkgsUnstable.google-cloud-sdk
      pkgsUnstable.gws
      pkgsLlmAgents.antigravity-cli
    ];

  # docker compose (v2 サブコマンド) の CLI プラグイン登録。
  # Homebrew の docker-compose は単体バイナリを置くのみで `docker compose` から
  # 認識されないため、~/.docker/cli-plugins/ に brew の opt パスを symlink する。
  # 手動で張ると Docker Desktop 削除時の zap で ~/.docker ごと消えるため、
  # home-manager 管理にして再現性を担保する (opt パスはバージョン非依存)。
  home.file.".docker/cli-plugins/docker-compose".source =
    config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/opt/docker-compose/bin/docker-compose";
}
