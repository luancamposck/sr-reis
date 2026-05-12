#!/usr/bin/env bash
set -euo pipefail

MAX_ITERATIONS="${1:-10}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAST_MESSAGE_FILE="$RALPH_DIR/state/.last-message"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"

PRD_FILE="$RALPH_DIR/state/prd.json"

"$RALPH_DIR/bin/doctor.sh"

for i in $(seq 1 "$MAX_ITERATIONS"); do
  log_info "Ralph Codex iteration $i of $MAX_ITERATIONS"

  "$RALPH_DIR/bin/run-once.sh"

  if ralph_all_stories_pass "$PRD_FILE"; then
    log_success "All stories pass"
    printf "<promise>COMPLETE</promise>\n"
    exit 0
  fi

  if [ -f "$LAST_MESSAGE_FILE" ] && grep -q "<promise>COMPLETE</promise>" "$LAST_MESSAGE_FILE"; then
    log_success "Completion signal found"
    exit 0
  fi

  sleep 2
done

log_error "Reached max iterations without completing all stories"
exit 1
