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
        username           = "shunsock";
        homeDirectory      = "/Users/shunsock";
        stateVersion       = "23.11";
        backupFileExtension = "backup";

        modules = [
          ({ pkgs, ... }: {
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

            home.file.".config/zsh".source    = ./zsh;
            home.file.".config/zsh".recursive = true;

            programs.zsh = {
              enable = true;

              # Oh My Zsh の有効化およびテーマ設定
              oh-my-zsh.enable  = true;
              oh-my-zsh.theme   = "kennethreitz";
              oh-my-zsh.plugins = [];

              # Zsh 設定を再帰的に読み込む
              initContent = ''
                setopt globstar
                for file in $HOME/.config/zsh/**/*.zsh; do
                  source "$file"
                done
                unsetopt globstar

                # zsh-autosuggestions は最後に source
                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
              '';
            };
          })
        ];
      };
    };
}

