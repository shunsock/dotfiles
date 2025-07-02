{
  description = "Flake for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs   = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      homeConfigurations."shunsock" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # モジュールで設定を一元管理
        modules = [
          ({ config, pkgs, ... }: {
            # 基本設定
            home.username      = "shunsock";
            home.homeDirectory = "/Users/shunsock";
            home.stateVersion  = "23.11";

            # 既存 .zshrc のバックアップを手動またはフラグで管理
            programs.home-manager.enable = true;

            # パッケージ
            home.packages = with pkgs; [
              claude-code
              dotnetCorePackages.dotnet_9.sdk
              git
              go-task
              hyperfine
              rustup
              tree
              zsh-autosuggestions
              zsh-syntax-highlighting
            ];

            # Zsh 設定ファイルを再帰的にコピー
            home.file.".config/zsh".source    = ./zsh;
            home.file.".config/zsh".recursive = true;

            # Zsh および Oh My Zsh 設定
            programs.zsh = {
              enable = true;
              # Oh My Zsh 有効化とテーマ設定
              oh-my-zsh.enable  = true;
              oh-my-zsh.theme   = "kennethreitz";
              oh-my-zsh.plugins = [];

              initContent = ''
                setopt globstar
                for file in $HOME/.config/zsh/**/*.zsh; do
                  source "$file"
                done
                unsetopt globstar

                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
              '';
            };
          })
        ];
      };
    };
}

