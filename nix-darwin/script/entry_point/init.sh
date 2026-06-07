#!/usr/bin/env bash
set -euo pipefail

# First-time bootstrap: experimental features may not be enabled in nix.conf yet,
# so pass them explicitly. Build as the current user, then switch with sudo via the
# prebuilt binary so root never re-evaluates the flake.
nix run --extra-experimental-features "nix-command flakes" github:LnL7/nix-darwin -- build --flake .#shunsock-darwin
sudo ./result/sw/bin/darwin-rebuild switch --flake .#shunsock-darwin
echo "nix-darwin has been installed system-wide. darwin-rebuild command is now available."
