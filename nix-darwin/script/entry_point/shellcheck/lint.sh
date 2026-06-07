#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/library/runner.sh"

# script/ 配下の全 .sh を収集する。
# mapfile は macOS 標準の bash 3.2 に無いため while-read で配列に積む。
shell_scripts=()
while IFS= read -r file; do
  shell_scripts+=("$file")
done < <(find "$SCRIPT_ROOT" -name '*.sh')

# -x             : source 先を辿って検査する
# --severity=warning : 動的 source パスで生じる SC1091(info) は対象外にする
run "シェルスクリプトの静的解析" \
  nix run nixpkgs#shellcheck -- -x --severity=warning "${shell_scripts[@]}"
