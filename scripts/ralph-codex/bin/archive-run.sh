#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PRD_FILE="$RALPH_DIR/state/prd.json"
PROGRESS_FILE="$RALPH_DIR/state/progress.txt"

BRANCH_NAME="$(jq -r '.branchName // "unknown-branch"' "$PRD_FILE" | sed 's|/|-|g')"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_DIR="$RALPH_DIR/archive/$STAMP-$BRANCH_NAME"

mkdir -p "$ARCHIVE_DIR"

cp "$PRD_FILE" "$ARCHIVE_DIR/prd.json"
cp "$PROGRESS_FILE" "$ARCHIVE_DIR/progress.txt"

echo "Archived Ralph Codex run to $ARCHIVE_DIR"
