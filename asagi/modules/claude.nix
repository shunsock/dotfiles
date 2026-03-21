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

  # validate-bash.sh hook をコピーとして配置（実行権限が必要）
  home.activation.claudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.claude/hooks
    run install -Dm755 ${../configs/claude/hooks/validate-bash.sh} $HOME/.claude/hooks/validate-bash.sh
  '';

  # cage プリセット設定
  home.file."Library/Application Support/cage/presets.yml".source = ../configs/cage/presets.yml;
}
