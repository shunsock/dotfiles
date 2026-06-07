#!/usr/bin/env bash
set -euo pipefail

# Switch with sudo via the prebuilt darwin-rebuild produced by build.sh, so root
# only activates the closure and never re-evaluates the flake. Run build.sh first.
sudo ./result/sw/bin/darwin-rebuild switch --flake .#shunsock-darwin
