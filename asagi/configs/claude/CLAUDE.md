# Claude Code Configuration

このファイルは、asagi プロジェクトで Claude Code が作業する際の動作指示書です。

## 構成

`configs/claude/` ディレクトリには以下の設定ファイルが含まれています：

- **skills/** - カスタムスキル定義
- **settings.json** - Claude Code の権限設定と環境変数
- **CLAUDE.md** (このファイル) - 各設定の参照と使用ガイドライン

詳細な技術情報やアーキテクチャについては、`../../CLAUDE.md` を参照してください。

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
- **AWS Permission Request** - AWS IAM権限申請メッセージ生成 (`./skills/aws_permission_request.md`)
  - エラーログとGit差分を元に権限申請メッセージを自動生成
- **Gemini Web Search** - Gemini CLI を使用した Web 検索 (`./skills/gemini_search.md`)
  - 組み込みweb_searchの代わりにGemini CLIを使用した高度な検索
- **Nix Packages Info** - HomeManager管理パッケージ情報取得 (`./skills/nix_packages_info.md`)
  - GitHubリポジトリからhome.nixを取得してパッケージ一覧を表示
