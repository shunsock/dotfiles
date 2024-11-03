{
  description = "My development environment with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # Define packages for arm64-darwin (Apple Silicon Mac)
    packages.aarch64-darwin = with nixpkgs.legacyPackages.aarch64-darwin; {
      ag = silver-searcher;
      fastfetch = fastfetch;
      go = go_1_22;
      hyperfine = hyperfine;
      neovim = neovim;
      nodejs = nodejs-18_x;
      php = php.withExtensions(exts: [ ]);
      rustup = rustup;
      task = go-task;
      tree = tree;
      wget = wget;

      default = neovim;
    };


    # Optionally define apps for nix run
    apps.aarch64-darwin.neovim = {
      type = "app";
      program = "${self.packages.aarch64-darwin.neovim}/bin/nvim";
    };
  };
}

