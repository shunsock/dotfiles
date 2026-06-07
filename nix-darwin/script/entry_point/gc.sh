#!/usr/bin/env bash
set -euo pipefail

# Keep the last 30 days of nix store paths.
nix-collect-garbage --delete-older-than 30d
