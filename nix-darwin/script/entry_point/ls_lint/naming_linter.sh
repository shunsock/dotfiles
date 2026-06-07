#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/library/logger.sh"

info "ファイル・ディレクトリ命名規則を検証します"
nix run nixpkgs#ls-lint
