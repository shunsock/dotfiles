#!/usr/bin/env bash
set -euo pipefail

# Build the system closure as the current user. ./result contains the prebuilt
# darwin-rebuild, which apply.sh reuses to switch under sudo without re-evaluating
# the flake (running Nix under sudo loses user config/auth and root-owns the cache).
nix run github:LnL7/nix-darwin -- build --flake .#shunsock-darwin
