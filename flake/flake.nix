{
  description = "My development environment with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.aarch64-darwin = with nixpkgs.legacyPackages.aarch64-darwin; {
      ag = silver-searcher;
      crystal = crystal;
      fastfetch = fastfetch;
      figlet = figlet;
      go = go_1_22;
      htop = htop;
      hyperfine = hyperfine;
      mold = mold;
      neovim = neovim;
      nodejs = nodejs-18_x;
      rustup = rustup;
      task = go-task;
      tree = tree;
      wget = wget;

      php = (pkgs.php.override {
        version = "8.4";
      }).withExtensions (exts: [ ]);

      default = neovim;
    };

    apps.aarch64-darwin.neovim = {
      type = "app";
      program = "${self.packages.aarch64-darwin.neovim}/bin/nvim";
    };
  };
}

