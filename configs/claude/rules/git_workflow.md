# Git Workflow Rule

## 自動実行の許可

以下の Git 操作はユーザーへの確認なしに自動で実行してよい：

- `git add` — 変更ファイルのステージング
- `git commit` — コミットの作成
- `git push` — リモートへのプッシュ（通常の push のみ）
- `gh pr create` — Pull Request の作成

これらの操作についてユーザーに「実行してよいですか？」と尋ねる必要はない。

## 禁止事項

以下の操作はユーザーの明示的な許可なく実行してはならない：

- `git push --force` / `git push -f`
- `git push --force-with-lease`
- `git reset --hard`
- `git branch -D`

これらは破壊的操作であり、必ずユーザーに確認してから実行する。
