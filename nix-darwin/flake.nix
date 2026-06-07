{
  description = "Flake for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      llm-agents,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      pkgsLlmAgents = llm-agents.packages.${system};

      complexity = pkgs.rustPlatform.buildRustPackage rec {
        pname = "complexity";
        version = "0.4.2";
        src = pkgs.fetchFromGitHub {
          owner = "thoughtbot";
          repo = "complexity";
          rev = version;
          hash = "sha256-lyc6ofDi7J2gIfBal1ARwxLzMtR+CdkCYumgMzQDghw=";
        };
        cargoHash = "sha256-c/1rm2rxoBAjK1abJHtjyhnmQq0WmXgZ7kdZy8pDOnM=";
      };
    in
    {
      # nixfmt 単体だと `nix fmt` が引数なしで呼ばれた際に空 stdin を読んで
      # パースエラーになるため、対象パス (既定はカレント) 配下の .nix を
      # 探索して nixfmt に渡すラッパーを formatter にする。
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = [
          pkgs.nixfmt-rfc-style
          pkgs.findutils
        ];
        text = ''
          if [ "$#" -eq 0 ]; then
            set -- .
          fi
          find "$@" -type f -name '*.nix' -print0 | xargs -0 -r nixfmt
        '';
      };

      darwinConfigurations."shunsock-darwin" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # System configuration
          {
            system.stateVersion = 4;
            system.primaryUser = "shunsock";
            nixpkgs.config.allowUnfree = true;
            ids.gids.nixbld = 350;

            # flake / nix-command を恒久的に有効化し、apply 後に
            # --extra-experimental-features フラグなしで nix コマンドを使えるようにする。
            # (init 時のブートストラップは Taskfile の inline フラグが担う)
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            # macOS system defaults
            system.defaults.NSGlobalDomain._HIHideMenuBar = true;
          }

          # Keyboard remapping configuration
          ./module/keymap.nix

          # Host configuration (Tailscale)
          ./module/host.nix

          # Homebrew configuration
          {
            homebrew = {
              enable = true;
              # Nix から削除したパッケージは activation 時に自動アンインストールする。
              # casks は関連ファイルまで削除する zap を採用 (brew は完全に Nix で一元管理)。
              onActivation = {
                cleanup = "zap";
                # カタログ (formula/cask 定義) は最新化するが、
                # インストール済みパッケージは固定して再現性を優先する。
                autoUpdate = true;
                upgrade = false;
                # Homebrew 5.1 以降、破壊的な `brew bundle --cleanup` は
                # --force-cleanup / --force / $HOMEBREW_ASK のいずれかを要求する。
                # nix-darwin は --force 系を生成しないため、cleanup を明示承認する。
                extraFlags = [ "--force-cleanup" ];
              };
              brews = [
                "colima"
                "curl"
              ];
              casks = [
                "aquaskk"
                "arc"
                "jetbrains-toolbox"
                "sf-symbols"
                "steam"
                "wezterm"
              ];
            };
          }

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit pkgsUnstable;
                inherit pkgsLlmAgents;
                inherit complexity;
              };

              users.shunsock = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}
