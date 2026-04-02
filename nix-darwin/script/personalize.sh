#!/usr/bin/env bash
# personalize.sh
#
# mainブランチの nix-darwin 設定 (ユーザー: shunsock) を
# 現在のmacOSユーザーに合わせて書き換えるスクリプト。
#
# 使い方:
#   bash nix-darwin/script/personalize.sh [ユーザー名]
#
# ユーザー名を省略した場合は現在のログインユーザー名を使用する。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NIX_DARWIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 元のユーザー名（mainブランチの値）
OLD_USER="shunsock"
OLD_DARWIN_CONFIG="shunsock-darwin"

# 新しいユーザー名
NEW_USER="${1:-$(whoami)}"
NEW_DARWIN_CONFIG="${NEW_USER%%.*}-darwin"

if [ "$OLD_USER" = "$NEW_USER" ]; then
  echo "ユーザー名が同じです ($OLD_USER)。変更不要です。"
  exit 0
fi

echo "=== nix-darwin 設定のパーソナライズ ==="
echo "  元ユーザー:   $OLD_USER"
echo "  新ユーザー:   $NEW_USER"
echo "  構成名:       $OLD_DARWIN_CONFIG -> $NEW_DARWIN_CONFIG"
echo ""

# --- flake.nix ---
echo "[1/7] flake.nix を更新..."
sed -i '' \
  -e "s/darwinConfigurations\\.\"${OLD_DARWIN_CONFIG}\"/darwinConfigurations.\"${NEW_DARWIN_CONFIG}\"/" \
  -e "s/system\\.primaryUser = \"${OLD_USER}\"/system.primaryUser = \"${NEW_USER}\"/" \
  -e "s/users\\.${OLD_USER} = import/users.\"${NEW_USER}\" = import/" \
  "$NIX_DARWIN_DIR/flake.nix"

# --- home.nix ---
echo "[2/7] home.nix を更新..."
sed -i '' \
  -e "s/home\\.username = \"${OLD_USER}\"/home.username = \"${NEW_USER}\"/" \
  -e "s|home\\.homeDirectory = lib\\.mkForce \"/Users/${OLD_USER}\"|home.homeDirectory = lib.mkForce \"/Users/${NEW_USER}\"|" \
  "$NIX_DARWIN_DIR/home.nix"

# --- Taskfile.yml ---
echo "[3/7] Taskfile.yml を更新..."
sed -i '' \
  -e "s/#${OLD_DARWIN_CONFIG}/#${NEW_DARWIN_CONFIG}/g" \
  "$NIX_DARWIN_DIR/Taskfile.yml"

# --- configs/bash/path.bash ---
echo "[4/7] configs/bash/path.bash を更新..."
sed -i '' \
  -e "s|per-user/${OLD_USER}/|per-user/${NEW_USER}/|g" \
  "$NIX_DARWIN_DIR/configs/bash/path.bash"

# --- configs/zsh/path.zsh ---
echo "[5/7] configs/zsh/path.zsh を更新..."
sed -i '' \
  -e "s|per-user/${OLD_USER}/|per-user/${NEW_USER}/|g" \
  "$NIX_DARWIN_DIR/configs/zsh/path.zsh"

# --- script/remove_backup.sh ---
echo "[6/7] script/remove_backup.sh を更新..."
sed -i '' \
  -e "s|/Users/${OLD_USER}/|/Users/${NEW_USER}/|g" \
  "$NIX_DARWIN_DIR/script/remove_backup.sh"

# --- CLAUDE.md, README.md ---
echo "[7/7] ドキュメントを更新..."
for doc in CLAUDE.md README.md; do
  if [ -f "$NIX_DARWIN_DIR/$doc" ]; then
    sed -i '' \
      -e "s/#${OLD_DARWIN_CONFIG}/#${NEW_DARWIN_CONFIG}/g" \
      -e "s/\\.${OLD_DARWIN_CONFIG}\\./.${NEW_DARWIN_CONFIG}./g" \
      -e "s/user \`${OLD_USER}\`/user \`${NEW_USER}\`/g" \
      -e "s|/Users/${OLD_USER}|/Users/${NEW_USER}|g" \
      "$NIX_DARWIN_DIR/$doc"
  fi
done

echo ""
echo "=== 完了 ==="
echo "flake.lock は 'nix flake update' で更新してください。"
echo "適用: task apply または sudo darwin-rebuild switch --flake .#${NEW_DARWIN_CONFIG}"
