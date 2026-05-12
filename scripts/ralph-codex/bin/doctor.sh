#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/../.." && pwd)"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"

log_info "Checking Ralph Codex environment"

command -v git >/dev/null || { log_error "git is required"; exit 1; }
command -v jq >/dev/null || { log_error "jq is required"; exit 1; }
command -v pnpm >/dev/null || { log_error "pnpm is required"; exit 1; }
command -v codex >/dev/null || { log_error "codex is required"; exit 1; }

[ -f "$REPO_ROOT/AGENTS.md" ] || { log_error "AGENTS.md not found at repo root"; exit 1; }
[ -f "$REPO_ROOT/package.json" ] || { log_error "package.json not found at repo root"; exit 1; }
[ -f "$REPO_ROOT/.codex/config.toml" ] || log_warn ".codex/config.toml not found"
[ -f "$RALPH_DIR/state/prd.json" ] || { log_error "state/prd.json not found"; exit 1; }
[ -f "$RALPH_DIR/state/progress.txt" ] || { log_error "state/progress.txt not found"; exit 1; }

ralph_validate_prd "$RALPH_DIR/state/prd.json" || {
  log_error "state/prd.json has invalid Ralph structure"
  exit 1
}

log_success "Ralph Codex environment looks ready"
