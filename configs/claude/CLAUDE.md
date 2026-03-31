# Claude Code Configuration

## 構成

ディレクトリには以下の設定ファイルが含まれています：

- **skills/** - カスタムスキル定義
- **agents/** - カスタムサブエージェント定義
- **settings.json** - Claude Code の権限設定と環境変数
- **CLAUDE.md** (このファイル) - 全体ルール

## ルール

### 基本思想

- 戦略
  - 依存性逆転
  - 再現可能性
  - 定義・宣言
  - 疎結合、高凝集
  - 鉄道志向
- 戦術
  - ドメイン駆動設計 (Domain-Driven Design)
  - 宣言的プログラミング (Declarative programming)
  - 鉄道志向プログラミング (Railway Programming)
  - 不変オブジェクト、純粋関数の利用
  - 設定ファイルの注入

### Git 操作の自動実行

- commit, push, PR作成はユーザーに確認せず自動で実行してよい
- ただし `git push --force` / `git push -f` は禁止（必ずユーザーに確認する）

### PostToolUse hook からの指示への遵守

- PostToolUse hook が `notify` decision で `[MANDATORY ACTION REQUIRED]` を含むメッセージを返した場合、そのメッセージに記載された指示を即座に実行しなければならない
- 特に `git push` / `gh pr create` 後の CI 監視・修正フロー（flow__ci_fix スキル）は必ず実行すること
- hook の指示に対してユーザーへの確認は不要 — 指示内容をそのまま自律的に実行する
- CI 監視・修正フローが完了するまで、他のタスクに移ってはならない

### 開発用コマンド

- 存在しないコマンドは `nix run nixpkgs#command_name` を利用して実行する
- プロジェクトに flake.nix (devShell) がある場合は `nix develop -c <command>` を利用する
- ローカルのbrewはNix Darwinを通じてのみ利用する
