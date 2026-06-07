#!/usr/bin/env bash
set -euo pipefail

# Bootstrap: nix.conf may not enable flakes yet, so pass the features explicitly.
nix run --extra-experimental-features "nix-command flakes" github:LnL7/nix-darwin -- build --flake .#shunsock-darwin
sudo ./result/sw/bin/darwin-rebuild switch --flake .#shunsock-darwin
echo "nix-darwin has been installed system-wide. darwin-rebuild command is now available."
