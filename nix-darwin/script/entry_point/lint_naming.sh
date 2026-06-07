#!/usr/bin/env bash
set -euo pipefail

nix run nixpkgs#ls-lint
