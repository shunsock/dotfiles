{
  description = "My development environment with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # Define packages for arm64-darwin (Apple Silicon Mac)
    packages.aarch64-darwin = with nixpkgs.legacyPackages.aarch64-darwin; {
      go = go_1_22;                   # go 1.22.7
      task = go-task;                 # go-task 3.38.0
      hyperfine = hyperfine;           # hyperfine 1.18.0
      neofetch = neofetch;             # neofetch unstable 2021-12-10
      neovim = neovim;                 # neovim 0.10.1
      nodejs = nodejs-18_x;            # nodejs 18.20.4
      php = php.withExtensions(exts: [ ]); # php-with-extensions 8.3.12 (add specific extensions if needed)
      rustup = rustup;                 # rustup 1.27.1
      ag = silver-searcher;            # Corrected to silver-searcher
      tree = tree;                     # tree 2.1.3
      wget = wget;                     # wget 1.24.5
    };

    # Set the default package (optional)
    defaultPackage.aarch64-darwin = self.packages.aarch64-darwin.neovim;

    # Optionally define apps for nix run
    apps.aarch64-darwin.neovim = {
      type = "app";
      program = "${self.packages.aarch64-darwin.neovim}/bin/nvim";
    };
  };
}

