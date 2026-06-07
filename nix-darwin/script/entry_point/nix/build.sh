#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/logger.sh"

info "nix-darwin 構成をビルドします (${FLAKE_REF})"
nix run "${NIX_DARWIN_FLAKE}" -- build --flake "${FLAKE_REF}"
