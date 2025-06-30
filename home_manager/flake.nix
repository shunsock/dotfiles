{
  description = "Flake for MacOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    homeConfigurations."shunsock" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit pkgs; };

      configuration = { pkgs, ... }: {
        home.username = "shunsock";
        home.homeDirectory = "/Users/shunsock";
        home.stateVersion = "23.11";
        programs.home-manager.enable = true;

        home.packages = with pkgs; [
          claude-code
          dotnetCorePackages.dotnet_9.sdk
          git
          go-task
          hyperfine
          rustup
          tree
        ];

        programs.zsh.enable = false;
      };
    };
  };
}

