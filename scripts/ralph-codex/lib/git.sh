#!/usr/bin/env bash
set -euo pipefail

ralph_git_root() {
  git rev-parse --show-toplevel
}

ralph_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

ralph_ensure_branch() {
  local branch_name="$1"

  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    git checkout "$branch_name"
  else
    git checkout -b "$branch_name"
  fi
}

ralph_has_changes() {
  ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]
}
