{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    package = null;  # Firefox installed via Homebrew

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      settings = {
        # Language
        "intl.accept_languages" = "en-US, en";

        # Theme
        "browser.theme.selected" = "firefox-compact-dark@mozilla.org-2";
        "browser.in-content.dark-mode" = true;

        # Wallpaper features
        "browser.newtabpage.activity-stream.newtabWallpapers.enabled" = true;
        "browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled" = true;
        "browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.enabled" = true;
        "browser.newtabpage.activity-stream.newtabWallpapers.customColor.enabled" = true;
      };
    };

    # NOTE: Enterprise policies cannot be used with Homebrew Firefox on macOS
    # They require placement in Firefox.app/Contents/Resources/distribution/
    # which breaks code signing and gets erased on updates.
    #
    # Configure these manually in Firefox (one-time setup):
    # 1. Search: Settings → Search → Default: DuckDuckGo
    # 2. Extensions: https://addons.mozilla.org/firefox/addon/bitwarden-password-manager/
    # 3. Sidebar: Settings → Sidebar → Enable vertical tabs, position: right
  };
}
