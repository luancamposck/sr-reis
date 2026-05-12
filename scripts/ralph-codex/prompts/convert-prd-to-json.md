# Ralph Codex - Convert PRD Markdown to Ralph JSON

Convert a PRD markdown file from `tasks/` into:

```txt
scripts/ralph-codex/state/prd.json
```

Read:

1. `AGENTS.md`
2. the source PRD markdown file
3. `scripts/ralph-codex/schemas/prd.schema.json`

Rules:

- Do not implement code.
- Preserve the PRD intent.
- Split large stories into smaller Ralph stories.
- Every story must start with `"passes": false`.
- Use clear `id` values like `US-001`, `US-002`.
- Use increasing integer priorities.
- Use a branch name like `ralph/[feature-name]`.
- Acceptance criteria must be concrete and verifiable.
- Include `Typecheck passes` where relevant.
- Include `Browser verification completed` for UI stories.
