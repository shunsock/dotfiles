# Custom Skill: Claude Settings Sync

あなたは、Claude Code の `settings.json` をNix管理のソース（dotfiles リポジトリ）と同期するエキスパートです。
プラグインインストール等で `~/.claude/settings.json` に追加された変更を検出し、Nix管理のソースファイルに反映してPRを作成します。

## 利用可能なツール
- Bash
- Read
- Edit

## 役割

`~/.claude/settings.json` はプラグインシステムによって書き込まれることがありますが、
Nixの宣言的管理（source of truth）は `shunsock/dotfiles` リポジトリの `asagi/configs/claude/settings.json` です。
`darwin-rebuild switch` のたびにNix側のファイルで上書きされるため、
プラグインが追加した変更をNix管理側に取り込まないと次回のリビルドで失われます。

このスキルは、両ファイルの差分を検出し、ユーザー確認のうえPRを作成して反映します。

## 前提条件

- `gh` CLI が認証済みであること
- `jq` がインストールされていること
- ローカルに dotfiles リポジトリが存在しない前提で動作する

## 実行手順

### Phase 1: 認証確認と作業ディレクトリ準備

```bash
# GitHub CLI認証確認
gh auth status

# 一時ディレクトリにリポジトリをクローン
WORK_DIR=$(mktemp -d)
gh repo clone shunsock/dotfiles "$WORK_DIR/dotfiles"
```

### Phase 2: 差分検出

以下の2ファイルを比較します:
- **Live**: `~/.claude/settings.json`（プラグインが書き込んだ可能性のあるファイル）
- **Source**: `${WORK_DIR}/dotfiles/asagi/configs/claude/settings.json`（Nix管理のソース）

```bash
diff <(jq --sort-keys . ~/.claude/settings.json) \
     <(jq --sort-keys . "$WORK_DIR/dotfiles/asagi/configs/claude/settings.json")
```

- 差分がない場合: 「同期済みです。変更はありません。」と報告し、作業ディレクトリを削除して終了
- 差分がある場合: Phase 3へ進む

### Phase 3: 差分の提示

差分内容をユーザーに分かりやすく提示します:

```bash
# Live側の追加・変更を確認
jq --sort-keys . ~/.claude/settings.json > /tmp/live_settings.json
jq --sort-keys . "$WORK_DIR/dotfiles/asagi/configs/claude/settings.json" > /tmp/source_settings.json
diff /tmp/live_settings.json /tmp/source_settings.json
```

以下の観点で整理して提示:
- 追加されたパーミッション（`permissions.allow` / `permissions.deny` / `permissions.ask`）
- 追加・変更された環境変数（`env`）
- その他の変更（`defaultMode` 等）

### Phase 4: ユーザー確認 [1]

ユーザーに以下を確認します:
- 差分の内容をNix管理のソースに反映するか
- 一部のみ反映する場合はどの項目か
- 反映しない場合は（次回 `darwin-rebuild switch` で失われることを通知）

### Phase 5: ブランチ作成とソースファイル更新

```bash
cd "$WORK_DIR/dotfiles"
git switch -c sync/claude-settings
```

ユーザーが承認した変更を `asagi/configs/claude/settings.json` に反映します。

- JSON整形は `jq` で実施（2スペースインデント: `jq --indent 2`）
- 既存の構造（`defaultMode`, `permissions`, `env`）を保持
- Read ツールでファイルを読み取り、Edit ツールで変更を適用

### Phase 6: コミットとPR作成

```bash
cd "$WORK_DIR/dotfiles"
git add asagi/configs/claude/settings.json
git commit -m "$(cat <<'EOF'
feat(asagi): sync claude settings.json with live configuration

- プラグインインストール等で追加された変更をNix管理側に反映

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push origin sync/claude-settings
```

PRを作成:
```bash
gh pr create \
  --repo shunsock/dotfiles \
  --title "feat(asagi): sync claude settings.json" \
  --body "$(cat <<'EOF'
## Summary
- `~/.claude/settings.json` のプラグイン変更をNix管理のソースに反映

## Changes
- `asagi/configs/claude/settings.json` を更新

## Context
`settings.json` は `home.activation` でコピーとして配置されており、
プラグインシステムが書き込み可能ですが、`darwin-rebuild switch` で上書きされます。
この PR で変更をNix管理側に取り込みます。
EOF
)"
```

### Phase 7: クリーンアップ

```bash
rm -rf "$WORK_DIR"
rm -f /tmp/live_settings.json /tmp/source_settings.json
```

PR の URL をユーザーに報告して完了。

## 注意

- Live ファイル (`~/.claude/settings.json`) は直接編集しません
- セキュリティに関わる権限（`permissions.deny` の削除など）は特に慎重に確認してください
- PR作成後、マージと `darwin-rebuild switch` の実行はユーザーが行います
