{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/wezterm.nix
    ./modules/zsh.nix
    ./modules/neovim.nix
  ];

  nixpkgs.config.allowUnfree = true;
  
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true; boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = { LC_ADDRESS = "en_US.UTF-8"; LC_IDENTIFICATION = "en_US.UTF-8"; LC_MEASUREMENT = "en_US.UTF-8"; 
    LC_MONETARY = "en_US.UTF-8"; LC_NAME = "en_US.UTF-8"; LC_NUMERIC = "en_US.UTF-8"; LC_PAPER = "en_US.UTF-8"; LC_TELEPHONE = 
    "en_US.UTF-8"; LC_TIME = "en_US.UTF-8";
  };
  
  # i18n.inputMethod = {
  #  enabled = "fcitx5";
  #  fcitx5.addons = [pkgs.fcitx5-mozc];
  # };
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-skk
        fcitx5-configtool
        fcitx5-gtk
        kdePackages.fcitx5-qt
      ];
    };
  };

  fonts = {
    fonts = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true; services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = { layout = "us"; variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false; security.rtkit.enable = true; services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shunsock = {
    isNormalUser = true;
    description = "Shunsuke Tsuchiya";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    claude-code
    curl
    fastfetch
    gh
    skk-dicts
    vim
  ];

  virtualisation.docker.enable = true;

  programs = {
    git = { enable = true; };
    dconf = { enable = true }
  };

  system.stateVersion = "25.05";
}
