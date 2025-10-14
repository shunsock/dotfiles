{ config, pkgs, ... }:

{
  # Install clipboard utilities for Linux
  environment.systemPackages = with pkgs; [
    wl-clipboard  # Wayland clipboard (for GNOME/Wayland)
    xclip         # X11 clipboard (fallback)
  ];

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Configure Neovim with clipboard support
    configure = {
      customRC = ''
        " Enable system clipboard integration
        set clipboard=unnamedplus

        " Use OSC52 for clipboard in terminal
        let g:clipboard = {
          \   'name': 'OSC 52',
          \   'copy': {
          \      '+': 'wl-copy',
          \      '*': 'wl-copy',
          \    },
          \   'paste': {
          \      '+': 'wl-paste --no-newline',
          \      '*': 'wl-paste --no-newline',
          \   },
          \   'cache_enabled': 1,
          \ }

        " Basic settings
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
      '';
    };
  };
}
