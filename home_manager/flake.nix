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
        modules = [
          ({ config, pkgs, ... }: {
            # 基本情報
            home.username      = "shunsock";
            home.homeDirectory = "/Users/shunsock";
            home.stateVersion  = "23.11";

            # 既存 ~/.zshrc をバックアップして置き換え
            home-manager.backupFileExtension = "backup";

            # パッケージ管理
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

            # zsh 設定ファイルを再帰的に配置
            home.file.".config/zsh".source    = ./zsh;
            home.file.".config/zsh".recursive = true;

            # Zsh および Oh My Zsh 設定
            programs.zsh = {
              enable = true;

              ohMyZsh = {
                enable  = true;
                theme   = "kennethreitz";
                plugins = [];
              };

              initContent = ''
                # 再帰的に全設定ファイルを読み込む
                setopt extendedglob
                for file in $HOME/.config/zsh/**/*.zsh; do
                  source "$file"
                done

                # zsh-autosuggestions は最後に読み込む
                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
              '';
            };
          })
        ];
      };
    };
}

