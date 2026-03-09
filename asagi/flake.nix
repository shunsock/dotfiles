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
    in
    {
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
                "curl"
                "steipete/tap/gogcli"
              ];
              casks = [
                "aquaskk"
                "cage"
                "arc"
                "docker-desktop"
                "firefox"
                "sf-symbols"
                "steam"
                "visual-studio-code"
                "wezterm"
                "zoom"
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
              };

              users.shunsock = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}
