#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.codex"

echo "Codex version:"
codex --version || true

echo "Project Codex config:"
if [ -f "/workspace/.codex/config.toml" ]; then
  echo "Found /workspace/.codex/config.toml"
else
  echo "WARN: /workspace/.codex/config.toml not found"
fi

echo "Home Codex config directory:"
echo "$HOME/.codex"

echo "Ralph Codex doctor:"
RALPH_ALLOW_PLACEHOLDER=1 bash /workspace/scripts/ralph-codex/bin/doctor.sh || true

cat <<'EOF'
Codex devcontainer setup complete.

Notes:
- Use /workspace/.codex/config.toml for project-level Codex config.
- Use ~/.codex for authentication/session/user config.
- If Codex asks whether to trust the project, trust this repository before relying on project config.
EOF
