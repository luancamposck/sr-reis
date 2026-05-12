#!/usr/bin/env bash
set -euo pipefail

ralph_default_checks() {
  if ! command -v pnpm >/dev/null; then
    echo "pnpm is required for Ralph checks" >&2
    return 1
  fi

  if [ ! -f package.json ]; then
    echo "package.json not found; cannot run Ralph checks" >&2
    return 1
  fi

  if declare -F log_info >/dev/null; then
    log_info "Running pnpm format"
  fi
  pnpm format

  if declare -F log_info >/dev/null; then
    log_info "Running pnpm lint"
  fi
  pnpm lint

  if declare -F log_info >/dev/null; then
    log_info "Running pnpm typecheck"
  fi
  pnpm typecheck
}
