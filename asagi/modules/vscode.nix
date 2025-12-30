{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    # Profile-based configuration (new in nixpkgs 25.11+)
    profiles.default = {
      # Extensions managed by Nix
      extensions = with pkgs.vscode-extensions; [
        # Remote Development Extension Pack
        # Includes: Remote-Containers, Remote-SSH, Remote-WSL, Dev Containers
        ms-vscode-remote.vscode-remote-extensionpack

        # VSCode Vim
        vscodevim.vim
      ];

      # Minimal default settings
      userSettings = {
        # Dev Containers Configuration (Apple Silicon paths)
        "dev.containers.dockerPath" = "/opt/homebrew/bin/docker";
        "dev.containers.dockerComposePath" = "/opt/homebrew/bin/docker-compose";

        # Basic Editor Settings
        "editor.formatOnSave" = true;
        "editor.rulers" = [
          80
          120
        ];
        "editor.tabSize" = 2;
        "files.autoSave" = "onFocusChange";

        # Terminal Integration (HackGen font already installed)
        "terminal.integrated.fontFamily" = "HackGen35 Console NF";
        "terminal.integrated.fontSize" = 14;

        # Theme
        "workbench.colorTheme" = "Default Dark Modern";
      };
    };
  };
}
