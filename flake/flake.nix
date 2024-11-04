{
  description = "My development environment with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.aarch64-darwin = with nixpkgs.legacyPackages.aarch64-darwin; {
      ag = silver-searcher;
      fastfetch = fastfetch;
      figlet = figlet;
      go = go_1_22;
      htop = htop;
      hyperfine = hyperfine;
      neovim = neovim;
      nodejs = nodejs-18_x;
      php = php.withExtensions(exts: [ ]);
      rustup = rustup;
      task = go-task;
      tree = tree;
      wget = wget;
      mold = mold;

      default = neovim;
    };

    apps.aarch64-darwin.neovim = {
      type = "app";
      program = "${self.packages.aarch64-darwin.neovim}/bin/nvim";
    };
  };
}

