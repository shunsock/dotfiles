{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true; boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/"; networking.proxy.noProxy = 
  # "127.0.0.1,localhost,internal.domain";

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
  
  i18n.inputMethod = {
   enabled = "fcitx5";
   fcitx5.addons = [pkgs.fcitx5-mozc];
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
    # If you want to use JACK applications, uncomment this jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default, no need to redefine it in your config 
    # for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager). services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shunsock = {
    isNormalUser = true;
    description = "Shunsuke Tsuchiya";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    curl
    wezterm
    claude-code
  ];
  virtualisation.docker.enable = true;

  programs = {
    git = { enable = true; };
    zsh = { enable = true; };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    starship = {
      enable = true;
    };
  };

  system.stateVersion = "25.05";
}
