#!/usr/bin/env bash
set -euo pipefail

# Switch via the prebuilt darwin-rebuild (build.sh) so root never re-evaluates under sudo.
sudo ./result/sw/bin/darwin-rebuild switch --flake .#shunsock-darwin
