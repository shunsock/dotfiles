{ config, lib, pkgs, ... }:

{
  # .claude 配下のディレクトリ・ファイルを個別にシンボリンク
  # settings.json はプラグインシステムが書き込むため除外
  home.file.".claude/CLAUDE.md".source = ../configs/claude/CLAUDE.md;
  home.file.".claude/agents" = {
    source = ../configs/claude/agents;
    recursive = true;
  };
  home.file.".claude/skills" = {
    source = ../configs/claude/skills;
    recursive = true;
  };
  home.file.".claude/rules" = {
    source = ../configs/claude/rules;
    recursive = true;
  };

  # settings.json はコピーとして配置（プラグインシステムが書き込み可能）
  # source of truth は configs/claude/settings.json
  # darwin-rebuild switch のたびに上書きされる
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../configs/claude/settings.json} $HOME/.claude/settings.json
  '';
}
