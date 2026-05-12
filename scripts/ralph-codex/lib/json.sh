#!/usr/bin/env bash
set -euo pipefail

ralph_next_story() {
  local prd_file="$1"

  jq -r '
    .userStories
    | map(select(.passes == false))
    | sort_by(.priority)
    | first
    | if . == null then "" else "\(.id) - \(.title)" end
  ' "$prd_file"
}

ralph_all_stories_pass() {
  local prd_file="$1"

  jq -e 'all(.userStories[]; .passes == true)' "$prd_file" >/dev/null
}

ralph_validate_prd() {
  local prd_file="$1"

  jq -e '
    type == "object"
    and (.project | type == "string")
    and (.branchName | type == "string")
    and (.description | type == "string")
    and (.userStories | type == "array")
    and (.userStories | length > 0)
    and all(.userStories[]; has("id") and has("title") and has("priority") and has("passes"))
  ' "$prd_file" >/dev/null
}
