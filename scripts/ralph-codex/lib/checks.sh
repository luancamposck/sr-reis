#!/usr/bin/env bash
set -euo pipefail

ralph_default_checks() {
  if [ -f package.json ]; then
    pnpm format
    pnpm lint
    pnpm typecheck
  fi
}
