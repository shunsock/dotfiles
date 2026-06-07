#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/const.sh"
source "$SCRIPT_ROOT/library/runner.sh"

run "${GC_KEEP_DURATION} より古い Nix store 世代の削除" \
  nix-collect-garbage --delete-older-than "${GC_KEEP_DURATION}"
