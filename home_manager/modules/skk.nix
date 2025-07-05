{ config, pkgs, ... }:

{
  # SKK configuration files
  home.file = {
    "Library/Application Support/AquaSKK/BlacklistApps.plist".source = ../configs/skk/BlacklistApps.plist;
    "Library/Application Support/AquaSKK/DictionarySet.plist".source = ../configs/skk/DictionarySet.plist;
    "Library/Application Support/AquaSKK/SKK-JISYO.L".source = ../configs/skk/SKK-JISYO.L;
    "Library/Application Support/AquaSKK/keymap.conf".source = ../configs/skk/keymap.conf;
    "Library/Application Support/AquaSKK/skk-jisho.user.utf8".source = ../configs/skk/skk-jisho.user.utf8;
    "Library/Application Support/AquaSKK/skk-jisyo.utf8".source = ../configs/skk/skk-jisyo.utf8;
  };
}