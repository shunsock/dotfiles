{
  description = "Flake for macOS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      darwinConfigurations."shunsock-darwin" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # System configuration
          {
            system.stateVersion = 4;
            system.primaryUser = "shunsock";
            nixpkgs.config.allowUnfree = true;
            ids.gids.nixbld = 350;
          }
          
          # Homebrew configuration
          {
            homebrew = {
              enable = true;
              casks = [
                "aquaskk"
                "docker"
                "wezterm"
                "zoom"
              ];
            };
          }
          
          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.shunsock = import ./home.nix;
            home-manager.backupFileExtension = "hm-backup";
          }
        ];
      };
    };
}

