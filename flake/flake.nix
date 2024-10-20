{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    # Define package for arm64-darwin (Apple Silicon Mac)
    packages.aarch64-darwin.hello = nixpkgs.legacyPackages.aarch64-darwin.hello;

    # Set the default package for aarch64-darwin
    defaultPackage.aarch64-darwin = self.packages.aarch64-darwin.hello;

    # Optionally, define an app (nix run looks for this)
    apps.aarch64-darwin.hello = {
      type = "app";
      program = "${self.packages.aarch64-darwin.hello}/bin/hello";
    };
  };
}
