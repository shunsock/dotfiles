#!/usr/bin/env bash
# remove_backup.sh
#
# Home Manager が activation 時に生成する *.hm-backup ファイルを削除する。
# 既存ファイルと衝突するとバックアップが残り、次回の apply を妨げるため掃除する。

set -euo pipefail

# entry_point/ から script/ へ 1 階層上って共有モジュールを読み込む。
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_ROOT/library/logger.sh"

# 存在すれば削除し、結果をログ出力する。存在しなくてもエラーにしない。
remove_if_exists() {
  local target="$1"
  if [ -e "$target" ]; then
    rm "$target"
    info "削除しました: $target"
  else
    info "ファイルが存在しません: $target"
  fi
}

readonly HOME_DIR="/Users/shunsuke.tsuchiya"
readonly BACKUP_FILES=(
  "$HOME_DIR/Library/Application Support/AquaSKK/skk-jisyo.utf8.hm-backup"
  "$HOME_DIR/Library/Application Support/AquaSKK/SKK-JISYO.L.hm-backup"
  "$HOME_DIR/Library/Application Support/Firefox/profiles.ini.hm-backup"
  "$HOME_DIR/.gemini/antigravity-cli/settings.json.hm-backup"
)

for backup in "${BACKUP_FILES[@]}"; do
  remove_if_exists "$backup"
done
