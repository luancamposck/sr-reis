#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/../.." && pwd)"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/git.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/codex.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/checks.sh"

PRD_FILE="$RALPH_DIR/state/prd.json"
PROGRESS_FILE="$RALPH_DIR/state/progress.txt"
PROMPT_FILE="$RALPH_DIR/prompts/run-story.md"
LAST_MESSAGE_FILE="$RALPH_DIR/state/.last-message"

cd "$REPO_ROOT"

"$RALPH_DIR/bin/doctor.sh"

BRANCH_NAME="$(jq -r '.branchName' "$PRD_FILE")"
NEXT_STORY="$(ralph_next_story "$PRD_FILE")"

if [ -z "$NEXT_STORY" ]; then
  log_success "All stories already pass"
  printf "<promise>COMPLETE</promise>\n"
  exit 0
fi

log_info "Ensuring branch: $BRANCH_NAME"
ralph_ensure_branch "$BRANCH_NAME"

BEFORE_HEAD="$(git rev-parse HEAD)"
BEFORE_PRD_HASH="$(sha256sum "$PRD_FILE" | awk '{print $1}')"
BEFORE_PROGRESS_HASH="$(sha256sum "$PROGRESS_FILE" | awk '{print $1}')"

log_info "Running Codex for next story: $NEXT_STORY"

if ! ralph_codex_command "$REPO_ROOT" "$PROMPT_FILE" "$LAST_MESSAGE_FILE"; then
  log_error "Codex execution failed"
  exit 1
fi

log_info "Running Ralph quality checks"
ralph_default_checks

if ralph_has_changes; then
  log_error "Quality checks left uncommitted changes"
  log_error "Commit or fix those changes before continuing"
  git status --short
  exit 1
fi

AFTER_HEAD="$(git rev-parse HEAD)"
AFTER_PRD_HASH="$(sha256sum "$PRD_FILE" | awk '{print $1}')"
AFTER_PROGRESS_HASH="$(sha256sum "$PROGRESS_FILE" | awk '{print $1}')"

if [ "$BEFORE_HEAD" = "$AFTER_HEAD" ] && [ "$BEFORE_PRD_HASH" = "$AFTER_PRD_HASH" ]; then
  log_error "Iteration did not create a commit or update prd.json"
  log_error "Refusing to continue silently"
  exit 1
fi

if [ "$BEFORE_PROGRESS_HASH" = "$AFTER_PROGRESS_HASH" ]; then
  log_warn "progress.txt was not updated"
fi

if grep -q "<promise>COMPLETE</promise>" "$LAST_MESSAGE_FILE"; then
  log_success "Codex reported completion"
fi

log_success "One Ralph Codex iteration finished"
