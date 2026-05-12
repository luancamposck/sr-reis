#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.codex"

if [ -f "/workspace/.codex/config.toml" ]; then
  ln -sf "/workspace/.codex/config.toml" "$HOME/.codex/project-config.toml"
fi

echo "Codex version:"
codex --version || true

echo "Ralph Codex doctor:"
RALPH_ALLOW_PLACEHOLDER=1 bash /workspace/scripts/ralph-codex/bin/doctor.sh || true
