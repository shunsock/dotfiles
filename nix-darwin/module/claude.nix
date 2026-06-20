{
  config,
  lib,
  pkgs,
  ...
}:

{
  # .claude 配下のディレクトリ・ファイルを個別にシンボリンク
  # 設定ファイルは configs/claude/ を single source of truth とする
  # settings.json はプラグインシステムが書き込むため除外
  home.file.".claude/CLAUDE.md".source = ../../configs/claude/CLAUDE.md;
  home.file.".claude/agents" = {
    source = ../../configs/claude/agents;
    recursive = true;
  };
  home.file.".claude/skills" = {
    source = ../../configs/claude/skills;
    recursive = true;
  };
  home.file.".claude/rules" = {
    source = ../../configs/claude/rules;
    recursive = true;
  };
  # settings.json はコピーとして配置（プラグインシステムが書き込み可能）
  # source of truth は configs/claude/settings.json
  # darwin-rebuild switch のたびに上書きされる
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../../configs/claude/settings.json} $HOME/.claude/settings.json
  '';

  # statusline スクリプトをコピーとして配置（実行権限が必要）
  home.activation.claudeStatusline = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm755 ${../../configs/claude/statusline.sh} $HOME/.claude/statusline.sh
  '';

  # hook スクリプトをコピーとして配置（実行権限が必要）
  home.activation.claudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.claude/hooks
    run install -Dm755 ${../../configs/claude/hooks/validate_bash.sh} $HOME/.claude/hooks/validate_bash.sh
    run install -Dm755 ${../../configs/claude/hooks/pr_submission_via_skill.sh} $HOME/.claude/hooks/pr_submission_via_skill.sh
    run install -Dm755 ${../../configs/claude/hooks/trigger_ci_fix.sh} $HOME/.claude/hooks/trigger_ci_fix.sh
    run install -Dm755 ${../../configs/claude/hooks/recommend_tasks.sh} $HOME/.claude/hooks/recommend_tasks.sh
    run install -Dm755 ${../../configs/claude/hooks/clean_comment_out.sh} $HOME/.claude/hooks/clean_comment_out.sh
  '';
}
