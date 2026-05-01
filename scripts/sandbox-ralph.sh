#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
exec nix run "$PROJECT_ROOT#sandbox-ralph" -- "$@"
