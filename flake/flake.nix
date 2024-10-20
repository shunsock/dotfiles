{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    # Define package for arm64-darwin (Apple Silicon Mac)
    packages.arm64-darwin.hello = nixpkgs.legacyPackages.aarch64-darwin.hello;

    # Set the default package for arm64-darwin
    defaultPackage.arm64-darwin = self.packages.arm64-darwin.hello;

  };
}

