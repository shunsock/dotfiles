#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/runner.sh"

# build.sh が生成済みの darwin-rebuild を使い、root が sudo 下で再評価しないようにする。
run "ビルド済み darwin-rebuild での構成適用 (${FLAKE_REF})" \
  sudo "${DARWIN_REBUILD_BIN}" switch --flake "${FLAKE_REF}"
