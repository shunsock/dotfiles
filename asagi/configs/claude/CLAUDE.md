# Claude Code Configuration

このファイルは、asagi プロジェクトで Claude Code が作業する際の動作指示書です。

## 構成

`configs/claude/` ディレクトリには以下の設定ファイルが含まれています：

- **agents/** - 専門的なタスクを処理するサブエージェント定義
- **commands/** - カスタムスラッシュコマンド（`/command_name` で呼び出し）
- **skills/** - カスタムスキル定義
- **settings.json** - Claude Code の権限設定と環境変数
- **CLAUDE.md** (このファイル) - 各設定の参照と使用ガイドライン

詳細な技術情報やアーキテクチャについては、`../../CLAUDE.md` を参照してください。

## Agents

特定のタスクは、専門的なサブエージェントに委譲してください：

- **Nix 操作**: Nix Command Agent (`./agents/nix_agent.md`)
- **Git/GitHub 操作**: Version Management System Agent (`./agents/git_gh_agent.md`)
- **Task 実行**: Go-Task Agent (`./agents/task_agent.md`)

## Commands

以下のカスタムスラッシュコマンドが利用可能です：

- `/gemini_search` - Gemini CLI を使用した Web 検索 (`./commands/gemini_search.md`)
- `/aws_permission_request` - AWS 権限申請メッセージ生成 (`./commands/aws_permission_request.md`)
- `/read_packages_managed_by_nix` - Nix 管理パッケージ情報取得 (`./commands/read_packages_managed_by_nix.md`)

## Custom Skills

以下のカスタムスキルが定義されています：

- **SDD Issue Maker** - スペック駆動開発の Issue 作成 (`./skills/sdd.md`)
  - Issue 作成時はこのガイドラインに厳格に従ってください
