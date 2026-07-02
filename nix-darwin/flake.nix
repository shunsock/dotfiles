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
    # lazynix は nixpkgs を nixos-25.11 にピンしており当方と一致するため follows で一本化する。
    lazynix.url = "github:shunsock/lazynix";
    lazynix.inputs.nixpkgs.follows = "nixpkgs";
    # hisui 上流は nixos-25.05 ピンだが、その dotnet SDK は aarch64-darwin で
    # configureNuget フェーズがクラッシュする。当方の nixos-25.11 に follows させて
    # 新しい dotnet SDK でビルドする。
    hisui.url = "github:shunsock/hisui";
    hisui.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      llm-agents,
      lazynix,
      hisui,
      ...
    }:
    let
      system = "aarch64-darwin";

      # ユーザー固有の値は単一の定義に集約し、flake.nix と home.nix で共有する。
      # home.nix はモジュールとして import されるため let スコープを共有できない。
      # extraSpecialArgs 経由で注入する (pkgsUnstable / complexity と同じ機構)。
      username = "shunsock";
      homeDirectory = "/Users/${username}";
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
      lazynixPkg = lazynix.packages.${system}.default;
      hisuiPkg = hisui.packages.${system}.default;

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

      darwinConfigurations."${username}-darwin" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # System configuration
          {
            system.stateVersion = 4;
            system.primaryUser = username;
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
            # メニューバーを常時表示する (自動的に隠さない)
            system.defaults.NSGlobalDomain._HIHideMenuBar = false;
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
                "docker"
                "docker-compose"
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

            # Docker Desktop (Docker.app) が /opt/homebrew 配下へ張る補完シンボリックリンクは
            # brews の `docker` formula の link ステップと衝突し、`brew bundle` を失敗させる。
            # Docker Desktop はこの構成の管理外 (casks 未登録) で、docker CLI は brew + Colima に
            # 一元化する方針のため、bundle 実行前 (extraActivation は homebrew ステップより先に走る) に
            # Docker.app を指す古い補完シンボリックリンクだけを除去する。
            # formula 側の補完は brew が改めて配置するため冪等かつ再現可能。
            system.activationScripts.extraActivation.text = ''
              for docker_completion in \
                /opt/homebrew/etc/bash_completion.d/docker \
                /opt/homebrew/share/fish/vendor_completions.d/docker.fish \
                /opt/homebrew/share/zsh/site-functions/_docker; do
                if [ -L "$docker_completion" ] && readlink "$docker_completion" | grep -q '/Applications/Docker.app/'; then
                  echo "removing stale Docker Desktop completion symlink: $docker_completion" >&2
                  rm -f "$docker_completion"
                fi
              done
            '';
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
                inherit lazynixPkg;
                inherit hisuiPkg;
                inherit username;
                inherit homeDirectory;
              };

              users.${username} = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}
