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
    samoyed = {
      url = "github:espiria/samoyed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      llm-agents,
      samoyed,
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
      # samoyed の上流 flake は古い rust-overlay と darwin.apple_sdk.frameworks.* に依存しており、
      # nixpkgs 25.11 では (a) legacy stub 削除で評価エラー、(b) rust-overlay 経由の rust-src が
      # 拡張子を持たないソースとして fetch され unpackPhase に失敗する。
      # よって上流の packages.default は使わず、ソースだけ拝借して nixpkgs の rustPlatform で
      # 自前ビルドする (Apple framework は現行 Darwin stdenv が自動供給するため省略可)。
      samoyedPkg = pkgs.rustPlatform.buildRustPackage {
        pname = "samoyed";
        version = "0.2.0";
        src = samoyed;
        cargoLock = {
          lockFile = "${samoyed}/Cargo.lock";
        };
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl ];
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
        # 内部テストは git init を sandbox 内で実行し失敗するため、ビルド時はスキップする。
        doCheck = false;
      };

      # thoughtbot/complexity: cognitive complexity measurement tool
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
      formatter.${system} = pkgs.nixfmt-rfc-style;

      darwinConfigurations."shunsuke-darwin" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # System configuration
          {
            system.stateVersion = 4;
            system.primaryUser = "shunsuke.tsuchiya";
            nixpkgs.config.allowUnfree = true;
            ids.gids.nixbld = 350;

            # macOS system defaults
            system.defaults.NSGlobalDomain._HIHideMenuBar = true;
          }

          # Keyboard remapping configuration
          ./modules/keymap.nix

          # Host configuration (Tailscale)
          ./modules/host.nix

          # Homebrew configuration
          {
            homebrew = {
              enable = true;
              taps = [
                "steipete/tap"
                "Warashi/tap"
              ];
              brews = [
                "colima"
                "curl"
                "steipete/tap/gogcli"
              ];
              casks = [
                "aquaskk"
                "arc"
                "docker-desktop"
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
                inherit samoyedPkg;
              };

              users."shunsuke.tsuchiya" = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}
