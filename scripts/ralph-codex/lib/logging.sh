#!/usr/bin/env bash
set -euo pipefail

log_info() {
  printf "\033[1;34m[info]\033[0m %s\n" "$*"
}

log_success() {
  printf "\033[1;32m[ok]\033[0m %s\n" "$*"
}

log_warn() {
  printf "\033[1;33m[warn]\033[0m %s\n" "$*"
}

log_error() {
  printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2
}
