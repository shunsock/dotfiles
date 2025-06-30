{
  description = "Flake for MacOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations."shunsock" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
      };

      username = "shunsock";
      homeDirectory = "/Users/shunsock";

      configuration = {
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

