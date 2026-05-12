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

BRANCH_NAME="$(jq -r '.branchName' "$RALPH_DIR/state/prd.json")"
DESCRIPTION="$(jq -r '.description' "$RALPH_DIR/state/prd.json")"

if [ "$BRANCH_NAME" = "ralph/example-feature" ] || printf "%s" "$DESCRIPTION" | grep -qi "placeholder"; then
  if [ "${RALPH_ALLOW_PLACEHOLDER:-}" = "1" ]; then
    log_warn "state/prd.json still contains the placeholder PRD"
    log_warn "Continuing because RALPH_ALLOW_PLACEHOLDER=1"
  else
    log_error "state/prd.json still contains the placeholder PRD"
    log_error "Replace it with a real PRD before running Ralph Codex"
    exit 1
  fi
fi

log_success "Ralph Codex environment looks ready"
