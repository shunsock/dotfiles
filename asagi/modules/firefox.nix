{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];

    preferences = {
      "intl.accept_languages" = "en-US, en";
      
      # 組み込みテーマ（Plum Torte）を ID で設定
      # このIDはバージョンによって変わる可能性があるため、注意が必要です。
      "browser.theme.selected" = "firefox-compact-dark@mozilla.org-2";
      
      # ブラウザがダークテーマを使用するように設定
      "browser.in-content.dark-mode" = true; 
    };

    policies = {
      # 検索エンジンをDuckDuckGoに設定
      DefaultSearchEngine = "DuckDuckGo";
      
      # 拡張機能 Bitwarden を強制インストール
      ExtensionSettings = {
        "bitwarden@bitwarden.com" = {
          install_url      = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      # 垂直タブの設定 (設定をロック)
      Preferences = {
        # 'lock-true' を正しい記法に修正
        "sidebar.revamp"      = { Value = true; Status = "locked"; };
        "sidebar.verticalTabs" = { Value = true; Status = "locked"; };
        
        # サイドバーの位置をロック (false = 右側)
        "sidebar.position_start" = { Value = false; Status = "locked"; };
      };
    };
  };
}
