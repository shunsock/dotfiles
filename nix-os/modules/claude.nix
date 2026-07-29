{ config, lib, pkgs, ... }:

{
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
  home.file.".claude/cli" = {
    source = ../../configs/claude/cli;
    recursive = true;
  };
  # CONSTRAINT: settings.json は Claude Code が実行時に書き込むため symlink 不可
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../../configs/claude/settings.json} $HOME/.claude/settings.json
  '';

  # CONSTRAINT: keybindings.json は /keybindings コマンドが実行時に書き込むため symlink 不可
  home.activation.claudeKeybindings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -Dm644 ${../../configs/claude/keybindings.json} $HOME/.claude/keybindings.json
  '';

  home.activation.claudeHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.claude/hooks
    run install -Dm644 ${../../configs/claude/hooks/validate_bash.cs} $HOME/.claude/hooks/validate_bash.cs
    run install -Dm644 ${../../configs/claude/hooks/pr_submission_via_skill.cs} $HOME/.claude/hooks/pr_submission_via_skill.cs
    run install -Dm644 ${../../configs/claude/hooks/trigger_ci_fix.cs} $HOME/.claude/hooks/trigger_ci_fix.cs
    run install -Dm644 ${../../configs/claude/hooks/require_tasks.cs} $HOME/.claude/hooks/require_tasks.cs
    run install -Dm644 ${../../configs/claude/hooks/block_stop_on_open_tasks.cs} $HOME/.claude/hooks/block_stop_on_open_tasks.cs
    run install -Dm644 ${../../configs/claude/hooks/write_structured_comment.cs} $HOME/.claude/hooks/write_structured_comment.cs
    run install -Dm644 ${../../configs/claude/hooks/clean_comment_out.cs} $HOME/.claude/hooks/clean_comment_out.cs
    run install -Dm644 ${../../configs/claude/hooks/validate_comment_format.cs} $HOME/.claude/hooks/validate_comment_format.cs
    run install -Dm644 ${../../configs/claude/hooks/validate_japanese_stop_word.cs} $HOME/.claude/hooks/validate_japanese_stop_word.cs
  '';
}
