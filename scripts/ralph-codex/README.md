# Ralph Codex-first

Ralph Codex-first is a local autonomous implementation loop for the `sr-reis` monorepo. It is inspired by Ralph, but this setup is designed for OpenAI Codex CLI from the start.

It does not depend on Claude, `.claude/skills`, `CLAUDE.md`, or the upstream Ralph runner. The project rules stay in the repository root `AGENTS.md`; operational loop prompts stay under `scripts/ralph-codex/prompts`.

## Workflow

1. Create a PRD markdown file under `tasks/`.
2. Convert the PRD markdown into `scripts/ralph-codex/state/prd.json`.
3. Review the PRD JSON before starting the loop.
4. Run one Codex story iteration or a bounded loop.

## Commands

Check the local Ralph Codex setup:

```bash
scripts/ralph-codex/bin/doctor.sh
```

Run exactly one story:

```bash
scripts/ralph-codex/bin/run-once.sh
```

Run up to 10 story iterations:

```bash
scripts/ralph-codex/bin/loop.sh 10
```

Archive the current `prd.json` and `progress.txt`:

```bash
scripts/ralph-codex/bin/archive-run.sh
```

Reset state files back to templates:

```bash
scripts/ralph-codex/bin/reset-run.sh
```

## PRD prompts

Create a PRD markdown from a feature idea with:

```txt
scripts/ralph-codex/prompts/create-prd.md
```

Convert a PRD markdown file into Ralph JSON with:

```txt
scripts/ralph-codex/prompts/convert-prd-to-json.md
```

Review the generated `prd.json` before running the loop with:

```txt
scripts/ralph-codex/prompts/review-prd.md
```

## State

The loop persists memory through:

- git history
- `AGENTS.md`
- `scripts/ralph-codex/state/prd.json`
- `scripts/ralph-codex/state/progress.txt`

`prd.json` and `progress.txt` are versioned on purpose. Runtime files such as `.last-message`, `.last-branch`, and archived runs are ignored.

## Notes

Do not run `loop.sh` with the placeholder PRD. Replace `scripts/ralph-codex/state/prd.json` with a real PRD first.
