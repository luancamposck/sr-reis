#!/usr/bin/env bash
set -euo pipefail

ralph_codex_command() {
  local repo_root="$1"
  local prompt_file="$2"
  local last_message_file="$3"

  : > "$last_message_file"

  local cmd="${CODEX_CMD:-codex exec --full-auto}"

  # shellcheck disable=SC2206
  local cmd_parts=($cmd)

  if codex exec --help 2>/dev/null | grep -q -- "--output-last-message"; then
    "${cmd_parts[@]}" \
      -C "$repo_root" \
      --output-last-message "$last_message_file" \
      < "$prompt_file"
  else
    "${cmd_parts[@]}" \
      -C "$repo_root" \
      < "$prompt_file" | tee "$last_message_file"
  fi
}
