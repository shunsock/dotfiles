#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/logger.sh"

# ブートストラップ: nix.conf がまだ flakes を有効化していない可能性があるため、機能を明示的に渡す。
info "nix-darwin をシステム全体へインストールします"
nix run --extra-experimental-features "nix-command flakes" "${NIX_DARWIN_FLAKE}" -- build --flake "${FLAKE_REF}"
sudo "${DARWIN_REBUILD_BIN}" switch --flake "${FLAKE_REF}"
info "nix-darwin のインストールが完了しました。darwin-rebuild コマンドが利用可能になりました。"
