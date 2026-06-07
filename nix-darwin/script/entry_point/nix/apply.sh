#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/logger.sh"

# build.sh が生成済みの darwin-rebuild を使い、root が sudo 下で再評価しないようにする。
info "ビルド済み darwin-rebuild で構成を適用します (${FLAKE_REF})"
sudo "${DARWIN_REBUILD_BIN}" switch --flake "${FLAKE_REF}"
