#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/library/runner.sh"

run "ファイル・ディレクトリ命名規則の検証" nix run nixpkgs#ls-lint
