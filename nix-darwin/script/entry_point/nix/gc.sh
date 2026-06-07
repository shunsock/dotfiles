#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/logger.sh"

info "${GC_KEEP_DURATION} より古い Nix store の世代を削除します"
nix-collect-garbage --delete-older-than "${GC_KEEP_DURATION}"
