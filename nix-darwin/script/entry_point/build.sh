#!/usr/bin/env bash
set -euo pipefail

nix run github:LnL7/nix-darwin -- build --flake .#shunsock-darwin
