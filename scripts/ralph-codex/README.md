# Ralph Codex-first

Ralph Codex-first is a local autonomous implementation loop for the `sr-reis` monorepo. It is inspired by Ralph, but this setup is designed for OpenAI Codex CLI from the start.

It does not depend on Claude, `.claude/skills`, `CLAUDE.md`, or the upstream Ralph runner. The project rules stay in the repository root `AGENTS.md`; operational loop prompts stay under `scripts/ralph-codex/prompts`.

## Workflow

1. Create a PRD markdown file under `tasks/`.
2. Convert the PRD markdown into `scripts/ralph-codex/state/prd.json`.
3. Review the PRD JSON before starting the loop.
4. Run one Codex story iteration or a bounded loop.

## Recommended Codex-first workflow

1. Open the repository inside the devcontainer.
2. Verify the scaffold:

   ```bash
   RALPH_ALLOW_PLACEHOLDER=1 bash scripts/ralph-codex/bin/doctor.sh
   ```

3. Use the `create-prd` skill to create a PRD under `tasks/`.
4. Use the `convert-prd-to-ralph-json` skill to create `scripts/ralph-codex/state/prd.json`.
5. Use the `review-ralph-prd` skill to review/refine `prd.json`.
6. Validate the real PRD:

   ```bash
   bash scripts/ralph-codex/bin/doctor.sh
   ```

7. Run one story first:

   ```bash
   bash scripts/ralph-codex/bin/run-once.sh
   ```

8. Only after one successful story, run a bounded loop:

   ```bash
   bash scripts/ralph-codex/bin/loop.sh 3
   ```

Do not run `run-once.sh` or `loop.sh` with the placeholder PRD.

## Agent Skills

Codex skills live under:

```txt
.agents/skills/
```

The skills provide the human-facing workflow:

- `create-prd`
- `convert-prd-to-ralph-json`
- `review-ralph-prd`

The detailed prompt contracts remain under:

```txt
scripts/ralph-codex/prompts/
```

The loop itself remains a shell-script workflow, not a skill.

## Devcontainer

The devcontainer is the recommended place to run Codex with high autonomy.

It provides:

- Node 20
- Codex CLI
- git/gh/jq/network tooling
- persistent `/home/node/.codex`
- firewall-based egress restrictions
- `/workspace` bind mount for the repository

The container reduces blast radius, but it does not protect the mounted repository from changes. Always work on a branch and keep commits small.

## Commands

Check the local Ralph Codex setup:

```bash
scripts/ralph-codex/bin/doctor.sh
```

`doctor.sh` fails while `scripts/ralph-codex/state/prd.json` still contains the placeholder PRD. For scaffold-only diagnostics before a real PRD exists, run:

```bash
RALPH_ALLOW_PLACEHOLDER=1 scripts/ralph-codex/bin/doctor.sh
```

Run exactly one story:

```bash
scripts/ralph-codex/bin/run-once.sh
```

`run-once.sh` runs the default quality checks after Codex returns as a safety net. If formatting, linting, or typecheck fails, or if those checks leave uncommitted changes, the script fails loudly.

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

## Design source

The original setup/design prompt is preserved at:

- `scripts/ralph-codex/docs/setup-source.md`

## Notes

Do not run `run-once.sh` or `loop.sh` while the placeholder PRD is active. Replace `scripts/ralph-codex/state/prd.json` with a real PRD first.
