{
  description = "Flake for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: let
    system = "aarch64-darwin";
    pkgs   = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
  in {
    homeConfigurations."shunsock" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      home-manager.backupFileExtension = "backup";

      modules = [
        ({ pkgs, ... }: {
          home.username      = "shunsock";
          home.homeDirectory = "/Users/shunsock";
          home.stateVersion  = "23.11";

          programs.home-manager.enable = true;

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

          # zsh 設定ファイルを再帰的にコピー
          home.file.".config/zsh".source    = ./zsh;
          home.file.".config/zsh".recursive = true;

          programs.zsh = {
            enable = true;

            oh-my-zsh = {
              enable  = true;
              theme   = "kennethreitz";
              plugins = [ ];
            };

            # initExtra は非推奨なので initContent に変更
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

