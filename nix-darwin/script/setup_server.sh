#!/usr/bin/env bash
# setup_server.sh
#
# macOS をサーバーとして運用するための初期設定スクリプト。
# Tailscale 越しにアクセスする汎用サーバーを想定。
#
# 設定内容:
#   1. スリープ無効化 (pmset)
#   2. SSH (リモートログイン) 有効化
#   3. アプリケーションファイアウォール有効化
#   4. 電源復帰時の自動起動
#   5. スクリーンセーバー無効化
#
# 使い方:
#   sudo bash nix-darwin/script/setup_server.sh
#
# 注意: このスクリプトは sudo で実行する必要があります。

set -euo pipefail

# --- root 権限チェック ---
if [ "$(id -u)" -ne 0 ]; then
  echo "エラー: このスクリプトは sudo で実行してください。"
  echo "  sudo bash $0"
  exit 1
fi

echo "=== macOS サーバー設定 ==="
echo ""

# --- [1/5] スリープ無効化 ---
echo "[1/5] スリープを無効化..."
# システムスリープ: 無効
pmset -a sleep 0
# ディスプレイスリープ: 無効
pmset -a displaysleep 0
# ディスクスリープ: 無効
pmset -a disksleep 0
echo "  完了: sleep=0, displaysleep=0, disksleep=0"

# --- [2/5] SSH 有効化 ---
echo "[2/5] SSH (リモートログイン) を有効化..."
systemsetup -setremotelogin on
echo "  完了: リモートログイン有効"

# --- [3/5] ファイアウォール有効化 ---
echo "[3/5] アプリケーションファイアウォールを有効化..."
FW="/usr/libexec/ApplicationFirewall/socketfilterfw"
# ファイアウォール ON
$FW --setglobalstate on
# 署名済みアプリの自動許可は OFF (必要なアプリだけ明示的に許可する)
$FW --setallowsigned off
$FW --setallowsignedapp off
# ステルスモード有効 (ping 応答を抑制)
$FW --setstealthmode on

# --- 許可するアプリを明示的に追加 ---
# SSH: Terminus / WezTerm からの接続用
$FW --add /usr/sbin/sshd
$FW --unblockapp /usr/sbin/sshd

# Docker: Docker Compose が公開するポートへの受信 HTTP 接続を許可する
# (ホスト側でポートをリッスンする Docker プロセスを許可対象にする)
# RSS サーバーは Vite dev server (5173) が /api を backend (3000) にプロキシするため、
# 外部からは 5173 のみアクセスできれば動作する
DOCKER_APPS=(
  "/Applications/Docker.app/Contents/MacOS/Docker"
  "/Applications/Docker.app/Contents/MacOS/com.docker.backend"
)
for app in "${DOCKER_APPS[@]}"; do
  if [ -f "$app" ]; then
    $FW --add "$app"
    $FW --unblockapp "$app"
    echo "  許可: $app"
  else
    echo "  スキップ (未インストール): $app"
  fi
done

echo "  完了: ファイアウォール有効, sshd + Docker のみ許可, ステルスモード有効"

# --- [4/5] 電源復帰時の自動起動 ---
echo "[4/5] 電源復帰時の自動起動を設定..."
# 電源喪失後の自動再起動
pmset -a autorestart 1
# Wake on LAN (Tailscale 利用時に有用)
pmset -a womp 1
echo "  完了: autorestart=1, womp=1"

# --- [5/5] スクリーンセーバー無効化 ---
echo "[5/5] スクリーンセーバーを無効化..."
# スクリーンセーバーの起動時間を0 (無効) に設定
# 実行ユーザーの設定を変更するため、SUDO_USER を利用
REAL_USER="${SUDO_USER:-$(whoami)}"
sudo -u "$REAL_USER" defaults -currentHost write com.apple.screensaver idleTime 0
echo "  完了: スクリーンセーバー無効"

echo ""
echo "=== 設定完了 ==="
echo ""
echo "現在の電源管理設定:"
pmset -g
echo ""
echo "ファイアウォール状態:"
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
echo ""
echo "注意:"
echo "  - Tailscale の設定は modules/host.nix で管理されています"
echo "  - SSH 接続は Tailscale ネットワーク経由を推奨します"
echo "  - 設定を元に戻すには各コマンドの値を変更してください"
