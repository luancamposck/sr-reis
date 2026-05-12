# Ralph Codex - Run One Story

You are Ralph running through OpenAI Codex CLI inside the `sr-reis` monorepo.

## Read first

Before changing files, read:

1. `AGENTS.md`
2. `scripts/ralph-codex/state/prd.json`
3. `scripts/ralph-codex/state/progress.txt`
4. Relevant `package.json` files for commands

## Core task

Implement exactly one user story per run.

Steps:

1. Read `scripts/ralph-codex/state/prd.json`.
2. Pick the highest-priority story where `passes === false`.
3. If all stories have `passes === true`, reply exactly:

   `<promise>COMPLETE</promise>`

4. Ensure you are on the branch defined by `branchName`.
5. Implement only the selected story.
6. Keep changes focused.
7. Run required checks.
8. Commit all changes for that story.
9. Update the selected story in `prd.json` to `"passes": true`.
10. Append a progress entry to `progress.txt`.

## Quality gate

Use the root monorepo commands unless the PRD says otherwise:

```bash
pnpm format
pnpm lint
pnpm typecheck
```

If a command does not exist, inspect `package.json` and use the closest correct script. Do not invent commands.

## Progress format

Append to `scripts/ralph-codex/state/progress.txt`:

```txt
## YYYY-MM-DD HH:mm UTC - US-XXX

- Implemented:
  - ...
- Files changed:
  - ...
- Quality gates:
  - ...
- Result:
  - ...
- Learnings for future iterations:
  - ...
---
```

Also update the `## Codebase Patterns` section at the top of `progress.txt` only when you discovered reusable information that future iterations should know.

## Commit format

Use:

```txt
feat: US-XXX - story title
```

or the best Conventional Commit type for the story:

```txt
fix:
refactor:
chore:
test:
docs:
```

Do not add `Co-Authored-By`.

## Hard rules

- Do not modify `AGENTS.md`.
- Do not modify Ralph Codex prompts unless the selected story explicitly requires it.
- Do not work on more than one story.
- Do not mark a story as passed unless checks passed.
- Do not commit broken code.
- Do not commit secrets.
- Do not reset remote databases.
- Do not delete existing migrations unless explicitly required by the selected story.
- Do not use service role outside server-only code.
