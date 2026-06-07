#!/usr/bin/env bash
set -euo pipefail

nix-collect-garbage --delete-older-than 30d
