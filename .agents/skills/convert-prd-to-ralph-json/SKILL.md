---
name: convert-prd-to-ralph-json
description: Convert a PRD markdown file under tasks/ into scripts/ralph-codex/state/prd.json for the Ralph Codex loop.
---

# Convert PRD to Ralph JSON Skill

You convert a PRD markdown file into Ralph Codex JSON state.

## Required reading

Before editing files, read:

1. `AGENTS.md`
2. `scripts/ralph-codex/prompts/convert-prd-to-json.md`
3. `scripts/ralph-codex/schemas/prd.schema.json`
4. The source PRD file under `tasks/`

## Output

Write the converted PRD to:

```txt
scripts/ralph-codex/state/prd.json
```

## Rules

- Do not implement code.
- Do not modify product files.
- Do not create migrations.
- Preserve the PRD intent.
- Split large stories into smaller Ralph stories.
- Every story must start with `"passes": false`.
- Use story IDs like `US-001`, `US-002`, `US-003`.
- Use increasing integer priorities.
- Use a valid feature branch name like `ralph/[feature-name]`.
- Acceptance criteria must be concrete and verifiable.
- Include `Typecheck passes` where relevant.
- Include `Browser verification completed` for UI stories.
- Include migrations/RLS/type generation criteria for database stories when relevant.

## Final response

After conversion, summarize:

- source PRD path
- output JSON path
- branchName chosen
- number of stories
- any stories that were split or reordered
