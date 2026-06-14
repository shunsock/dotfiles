{
  description = "Flake for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      noctalia,
      llm-agents,
      ...
    }:
    let
      system = "x86_64-linux";
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

      # thoughtbot/complexity: cognitive complexity measurement tool
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
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = {
        myNixOS = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            noctalia.nixosModules.default

            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                extraSpecialArgs = {
                  inherit pkgsUnstable;
                  inherit pkgsLlmAgents;
                  inherit complexity;
                };

                users.shunsock = import ./home.nix;

                backupFileExtension = "hm-backup";
              };
            }
          ];
        };
      };
    };
}
