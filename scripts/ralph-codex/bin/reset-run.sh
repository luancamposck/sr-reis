#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cp "$RALPH_DIR/templates/prd.template.json" "$RALPH_DIR/state/prd.json"
cp "$RALPH_DIR/templates/progress.template.txt" "$RALPH_DIR/state/progress.txt"
rm -f "$RALPH_DIR/state/.last-message"
rm -f "$RALPH_DIR/state/.last-branch"

echo "Ralph Codex state reset"
