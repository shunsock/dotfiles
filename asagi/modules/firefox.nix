{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    languagePacks = [ "en-US" ];

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "intl.accept_languages" = "en-US, en";
        "browser.theme.selected" = "firefox-compact-dark@mozilla.org-2";
        "browser.in-content.dark-mode" = true;
      };
    };

    policies = {
      SearchEngines = {
        Default = "DuckDuckGo";
      };

      ExtensionSettings = {
        "bitwarden@bitwarden.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      Preferences = {
        "sidebar.revamp" = {
          Value = true;
          Status = "locked";
        };
        "sidebar.verticalTabs" = {
          Value = true;
          Status = "locked";
        };
        "sidebar.position_start" = {
          Value = false;
          Status = "locked";
        };
      };
    };
  };
}
