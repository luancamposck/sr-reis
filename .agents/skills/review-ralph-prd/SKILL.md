---
name: review-ralph-prd
description: Review and refine scripts/ralph-codex/state/prd.json before running the Ralph Codex loop.
---

# Review Ralph PRD Skill

You review `scripts/ralph-codex/state/prd.json` before the Ralph Codex loop runs.

## Required reading

Before editing files, read:

1. `AGENTS.md`
2. `scripts/ralph-codex/prompts/review-prd.md`
3. `scripts/ralph-codex/schemas/prd.schema.json`
4. `scripts/ralph-codex/state/prd.json`

## Scope

You may update only:

```txt
scripts/ralph-codex/state/prd.json
```

Do not implement code.

## Review checklist

Check that:

- Stories are small enough for one iteration.
- Priorities are ordered by dependency.
- Acceptance criteria are concrete and verifiable.
- UI stories mention browser verification.
- Database stories mention migrations, RLS, and type generation when relevant.
- No story mixes unrelated backend, frontend, and database work unless unavoidable.
- `branchName` is valid, specific, and not `ralph/example-feature`.
- No story is already marked `"passes": true` before the first loop unless intentionally completed.

## Final response

After review, summarize:

- whether the PRD was changed
- stories changed
- remaining risks
- whether `bash scripts/ralph-codex/bin/doctor.sh` should now pass
