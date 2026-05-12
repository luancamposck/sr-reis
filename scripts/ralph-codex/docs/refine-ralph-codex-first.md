# Refine Ralph Codex-first Scaffold

> Use this file as a prompt for Codex CLI inside the local `sr-reis` repository.
> Suggested path: `tasks/refine-ralph-codex-first.md`

---

## 0. How to run

From the repository root:

```bash
git checkout main
git pull

# Prefer a branch for this cleanup.
git checkout -b chore/refine-ralph-codex-first

mkdir -p tasks
# Save this file as:
# tasks/refine-ralph-codex-first.md

codex exec -C . < tasks/refine-ralph-codex-first.md
```

Do not run the real Ralph loop as part of this task.

---

## 1. Goal

Refine the existing Ralph Codex-first scaffold under:

```txt
scripts/ralph-codex/
```

This is not a new scaffold. The scaffold already exists. Make a small cleanup/improvement pass.

---

## 2. Existing context

This repository is the `sr-reis` monorepo.

Important files already exist:

```txt
AGENTS.md
.codex/config.toml
scripts/ralph-codex/README.md
scripts/ralph-codex/bin/doctor.sh
scripts/ralph-codex/bin/run-once.sh
scripts/ralph-codex/bin/loop.sh
scripts/ralph-codex/bin/archive-run.sh
scripts/ralph-codex/bin/reset-run.sh
scripts/ralph-codex/lib/checks.sh
scripts/ralph-codex/lib/codex.sh
scripts/ralph-codex/lib/git.sh
scripts/ralph-codex/lib/json.sh
scripts/ralph-codex/lib/logging.sh
scripts/ralph-codex/prompts/create-prd.md
scripts/ralph-codex/prompts/convert-prd-to-json.md
scripts/ralph-codex/prompts/review-prd.md
scripts/ralph-codex/prompts/run-story.md
scripts/ralph-codex/state/prd.json
scripts/ralph-codex/state/progress.txt
scripts/ralph-codex/templates/prd.template.json
scripts/ralph-codex/templates/progress.template.txt
tasks/setup-ralph-codex-first.md
```

`tasks/setup-ralph-codex-first.md` is the original design/prompt document used to generate the scaffold. It must be preserved as documentation, but it does not need to stay under `tasks/`.

---

## 3. Hard rules

- Do not modify `AGENTS.md`.
- Do not modify product/app code.
- Do not create migrations.
- Do not add npm dependencies.
- Do not add secrets.
- Do not run the real Ralph loop.
- Do not delete `tasks/setup-ralph-codex-first.md` without preserving its content elsewhere.
- Keep changes limited to:
  - `scripts/ralph-codex/**`
  - `.gitignore`
  - `.codex/config.toml` only if absolutely necessary
  - `tasks/setup-ralph-codex-first.md` only to move it into docs

---

## 4. Required changes

### 4.1 Preserve the original setup prompt as documentation

Move:

```txt
tasks/setup-ralph-codex-first.md
```

to:

```txt
scripts/ralph-codex/docs/setup-source.md
```

Create the `docs/` directory if needed.

After moving, update `scripts/ralph-codex/README.md` to mention:

```md
## Design source

The original setup/design prompt is preserved at:

- `scripts/ralph-codex/docs/setup-source.md`
```

Do not leave a duplicate copy in `tasks/`.

Expected result:

```txt
scripts/ralph-codex/docs/setup-source.md
```

exists and contains the original documentation.

```txt
tasks/setup-ralph-codex-first.md
```

does not exist anymore.

---

### 4.2 Add placeholder PRD protection to `doctor.sh`

Currently `scripts/ralph-codex/state/prd.json` is a placeholder and has:

```json
{
  "branchName": "ralph/example-feature",
  "description": "Placeholder PRD for Ralph Codex. Replace this file before running a real loop."
}
```

This is dangerous because someone can accidentally run `run-once.sh` and make Codex implement the placeholder story.

Update `scripts/ralph-codex/bin/doctor.sh` so it fails when the state PRD is still the placeholder.

After validating the PRD structure, add logic equivalent to:

```bash
BRANCH_NAME="$(jq -r '.branchName' "$RALPH_DIR/state/prd.json")"
DESCRIPTION="$(jq -r '.description' "$RALPH_DIR/state/prd.json")"

if [ "$BRANCH_NAME" = "ralph/example-feature" ] || printf "%s" "$DESCRIPTION" | grep -qi "placeholder"; then
  log_error "state/prd.json still contains the placeholder PRD"
  log_error "Replace it with a real PRD before running Ralph Codex"
  exit 1
fi
```

The exact implementation can be improved, but behavior must be:

```txt
doctor.sh fails if the placeholder PRD is active.
```

Important: `reset-run.sh` may still restore the placeholder template. That is okay. The point is to prevent accidental real runs.

---

### 4.3 Add an explicit "allow placeholder" mode for diagnostics

Because `doctor.sh` will fail with placeholder PRD, add an explicit environment escape hatch for scaffold testing:

```bash
RALPH_ALLOW_PLACEHOLDER=1 scripts/ralph-codex/bin/doctor.sh
```

When `RALPH_ALLOW_PLACEHOLDER=1`, `doctor.sh` should warn instead of failing.

Behavior:

```txt
Without RALPH_ALLOW_PLACEHOLDER=1:
  placeholder PRD => fail

With RALPH_ALLOW_PLACEHOLDER=1:
  placeholder PRD => warn and continue
```

This is useful to check the scaffold before a real PRD exists.

Update `README.md` to document this:

```bash
RALPH_ALLOW_PLACEHOLDER=1 scripts/ralph-codex/bin/doctor.sh
```

---

### 4.4 Make `run-once.sh` use `lib/checks.sh`

`lib/checks.sh` exists, but `run-once.sh` does not currently source or call it.

Update `scripts/ralph-codex/bin/run-once.sh`:

1. Source the checks library:

```bash
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/checks.sh"
```

2. After the Codex command finishes successfully, run:

```bash
log_info "Running Ralph quality checks"
ralph_default_checks
```

3. If the checks fail, the script must fail.

4. After checks, detect if the working tree is dirty because checks modified files or generated changes:

```bash
if ralph_has_changes; then
  log_error "Quality checks left uncommitted changes"
  log_error "Commit or fix those changes before continuing"
  git status --short
  exit 1
fi
```

Important reasoning:

- The prompt already tells Codex to run checks before committing.
- This script-level check is a safety net.
- If `pnpm format` changes files after Codex committed, that means the Codex iteration was not truly clean, so fail loudly.

---

### 4.5 Improve `lib/checks.sh` for monorepo safety

Current implementation:

```bash
ralph_default_checks() {
  if [ -f package.json ]; then
    pnpm format
    pnpm lint
    pnpm typecheck
  fi
}
```

Refine it slightly:

- Check that `pnpm` exists.
- Check that `package.json` exists.
- Use root scripts only.
- Do not invent package filters.
- Log what is being run if logging functions are available.

Suggested implementation:

```bash
ralph_default_checks() {
  if ! command -v pnpm >/dev/null; then
    echo "pnpm is required for Ralph checks" >&2
    return 1
  fi

  if [ ! -f package.json ]; then
    echo "package.json not found; cannot run Ralph checks" >&2
    return 1
  fi

  pnpm format
  pnpm lint
  pnpm typecheck
}
```

Optional: use `log_info` only if it exists:

```bash
if declare -F log_info >/dev/null; then
  log_info "Running pnpm format"
fi
```

---

### 4.6 README updates

Update `scripts/ralph-codex/README.md` to explain:

1. The design source file:

```txt
scripts/ralph-codex/docs/setup-source.md
```

2. Placeholder PRD protection:

```bash
scripts/ralph-codex/bin/doctor.sh
```

will fail while `state/prd.json` is still the placeholder.

3. Scaffold-only doctor mode:

```bash
RALPH_ALLOW_PLACEHOLDER=1 scripts/ralph-codex/bin/doctor.sh
```

4. `run-once.sh` runs quality checks as a safety net after Codex returns.

5. Do not run `loop.sh` until `state/prd.json` has a real PRD.

---

## 5. Optional cleanup

If there are empty directories left under `tasks/`, leave them alone unless Git tracks files inside them.

Do not add `.gitkeep` unless already used in this repo.

---

## 6. Validation commands

After changes, run:

```bash
RALPH_ALLOW_PLACEHOLDER=1 bash scripts/ralph-codex/bin/doctor.sh
```

Do not run:

```bash
scripts/ralph-codex/bin/run-once.sh
scripts/ralph-codex/bin/loop.sh
```

because the PRD is still placeholder.

Also run:

```bash
git status --short
```

Expected changed files should be limited to something like:

```txt
M  scripts/ralph-codex/README.md
M  scripts/ralph-codex/bin/doctor.sh
M  scripts/ralph-codex/bin/run-once.sh
M  scripts/ralph-codex/lib/checks.sh
R  tasks/setup-ralph-codex-first.md -> scripts/ralph-codex/docs/setup-source.md
```

---

## 7. Acceptance criteria

- [ ] `AGENTS.md` was not modified.
- [ ] Product/app code was not modified.
- [ ] `tasks/setup-ralph-codex-first.md` was preserved as `scripts/ralph-codex/docs/setup-source.md`.
- [ ] `tasks/setup-ralph-codex-first.md` no longer exists as a duplicate.
- [ ] `README.md` links/mentions `docs/setup-source.md`.
- [ ] `doctor.sh` fails on placeholder PRD by default.
- [ ] `doctor.sh` passes on placeholder PRD only with `RALPH_ALLOW_PLACEHOLDER=1`.
- [ ] `run-once.sh` sources `lib/checks.sh`.
- [ ] `run-once.sh` runs `ralph_default_checks` after Codex returns.
- [ ] `run-once.sh` fails if quality checks leave uncommitted changes.
- [ ] `lib/checks.sh` is safe and explicit for the monorepo.
- [ ] `RALPH_ALLOW_PLACEHOLDER=1 bash scripts/ralph-codex/bin/doctor.sh` succeeds.
- [ ] No real Ralph loop was run.

---

## 8. Suggested commit

```bash
git add scripts/ralph-codex tasks .gitignore
git commit -m "chore: refine Ralph Codex scaffold"
```

---

## 9. Final response expected from Codex

At the end, summarize:

- files changed;
- whether `AGENTS.md` stayed untouched;
- validation command output;
- any command that failed and why.
