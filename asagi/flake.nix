{
  description = "Flake for macOS"; inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nixpkgs-firefox-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { 
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    nixpkgs-firefox-darwin,
    ...
  }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ nixpkgs-firefox-darwin.overlay ];
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      formatter.${system} = pkgs.nixfmt-rfc-style;

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
                "arc"
                "docker"
                "steam"
                "wezterm"
                "zoom"
              ];
            };
          }
          
          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs   = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit pkgsUnstable;
              };

              users.shunsock = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}

