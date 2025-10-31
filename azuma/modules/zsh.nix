{ config, pkgs, ... }:

{
  # Install zsh plugins
  environment.systemPackages = with pkgs; [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  # Deploy zsh configuration files to system-wide location
  environment.etc."zsh/custom/basic/option.zsh".source = ../configs/zsh/basic/option.zsh;
  environment.etc."zsh/custom/basic/alias.zsh".source = ../configs/zsh/basic/alias.zsh;
  environment.etc."zsh/custom/command/git/alias.zsh".source = ../configs/zsh/command/git/alias.zsh;
  environment.etc."zsh/custom/command/docker/docker.zsh".source = ../configs/zsh/command/docker/docker.zsh;

  # Zsh and Oh My Zsh configuration
  programs.zsh = {
    enable = true;

    # Enable Oh My Zsh
    ohMyZsh = {
      enable = false;
      theme = "kennethreitz";
      plugins = [];
    };

    # Source custom configuration files
    interactiveShellInit = ''
      unalias -m '*'

      # Source all custom zsh files from /etc/zsh/custom
      # setopt extendedglob
      # for f in /etc/zsh/custom/**/*.zsh; do
      #  source "$f"
      # done

      # Load zsh-autosuggestions (must be loaded after other configs)
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };
}
