# Claude Code Configuration

このファイルは、asagi プロジェクトで Claude Code が作業する際の動作指示書です。

## 構成

`configs/claude/` ディレクトリには以下の設定ファイルが含まれています：

- **commands/** - カスタムスラッシュコマンド（`/command_name` で呼び出し）
- **skills/** - カスタムスキル定義
- **settings.json** - Claude Code の権限設定と環境変数
- **CLAUDE.md** (このファイル) - 各設定の参照と使用ガイドライン

詳細な技術情報やアーキテクチャについては、`../../CLAUDE.md` を参照してください。

## Commands

以下のカスタムスラッシュコマンドが利用可能です：

- `/gemini_search` - Gemini CLI を使用した Web 検索 (`./commands/gemini_search.md`)
- `/aws_permission_request` - AWS 権限申請メッセージ生成 (`./commands/aws_permission_request.md`)
- `/read_packages_managed_by_nix` - Nix 管理パッケージ情報取得 (`./commands/read_packages_managed_by_nix.md`)

## Custom Skills

以下のカスタムスキルが定義されています：

- **SDD Issue Maker** - スペック駆動開発の Issue 作成 (`./skills/sdd.md`)
  - Issue 作成時はこのガイドラインに厳格に従ってください
- **Version Management System** - Git/GitHub 操作 (`./skills/git_gh.md`)
  - リポジトリ操作、コミット、プルリクエスト、Issue管理などのタスク
- **Nix Command** - Nix パッケージ管理 (`./skills/nix.md`)
  - パッケージ管理、システム設定、開発環境構築
- **Go-Task** - Taskfile.yml タスク実行 (`./skills/task.md`)
  - Taskfile.ymlに定義されたタスクの実行と管理
