# Ralph Codex - Review PRD Before Loop

Review `scripts/ralph-codex/state/prd.json` before running the Ralph loop.

Read:

1. `AGENTS.md`
2. `scripts/ralph-codex/state/prd.json`
3. `scripts/ralph-codex/schemas/prd.schema.json`

Do not implement anything.

Check:

- Stories are small enough for one iteration.
- Priorities are ordered by dependency.
- Acceptance criteria are verifiable.
- UI stories mention browser verification.
- Database stories mention migrations, RLS and type generation when needed.
- No story mixes unrelated backend, frontend and database work unless unavoidable.
- The branchName is valid and specific.

If improvements are needed, update only `scripts/ralph-codex/state/prd.json` and explain the changes in your final response.
