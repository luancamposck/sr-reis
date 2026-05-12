# Task: Finalize Codex-first Ralph Workflow with Devcontainer and Agent Skills

> Suggested path in repo: `tasks/finalize-codex-ralph-workflow.md`  
> Run this prompt with Codex CLI from the repository root.

---

## 0. Recommended execution

Run from the `sr-reis` repository root.

Prefer a feature branch:

```bash
git checkout main
git pull
git checkout -b chore/finalize-codex-ralph-workflow

mkdir -p tasks
# Save this file as:
# tasks/finalize-codex-ralph-workflow.md

codex exec -C . < tasks/finalize-codex-ralph-workflow.md
```

Do not start a real Ralph loop during this task.

---

## 1. Goal

Finalize the local **Codex-first Ralph workflow** before creating the first real PRD.

The repository already has:

```txt
AGENTS.md
.codex/config.toml
.devcontainer/
scripts/ralph-codex/
```

This task must:

1. Keep the devcontainer sandbox model.
2. Add Codex Agent Skills under `.agents/skills/`.
3. Keep `scripts/ralph-codex/prompts/` as the canonical detailed prompt source.
4. Fix the operational order in `run-story.md`.
5. Improve devcontainer consistency.
6. Update documentation so the workflow is clear before the first PRD/loop.

---

## 2. Current state observed

The latest relevant commit is:

```txt
feat(devcontainer): add Dockerfile, init-firewall script, and setup script for Codex environment
```

It added:

```txt
.devcontainer/Dockerfile
.devcontainer/devcontainer.json
.devcontainer/init-firewall.sh
.devcontainer/setup-codex.sh
```

The devcontainer is named `Codex Sandbox`, builds from `.devcontainer/Dockerfile`, mounts the repo at `/workspace`, persists `/home/node/.codex`, and runs the firewall on start.

Important current details:

- `.devcontainer/Dockerfile` installs `zsh`, configures `SHELL=/bin/zsh`, and installs `@openai/codex@${CODEX_VERSION}`.
- `.devcontainer/devcontainer.json` currently sets VS Code default terminal profile to `fish`, but the Dockerfile does not install fish.
- `.devcontainer/setup-codex.sh` creates `$HOME/.codex` and symlinks `/workspace/.codex/config.toml` to `$HOME/.codex/project-config.toml`.
- `scripts/ralph-codex/prompts/run-story.md` currently tells the agent to commit before updating `prd.json` and `progress.txt`, which is unsafe with the current `run-once.sh` safety checks.
- `scripts/ralph-codex/bin/run-once.sh` runs quality checks after Codex returns and fails if checks leave uncommitted changes.
- `scripts/ralph-codex/bin/doctor.sh` blocks placeholder PRDs unless `RALPH_ALLOW_PLACEHOLDER=1`.

---

## 3. Design decisions

### 3.1 Devcontainer before PRD/loop

Do not start a PRD or Ralph loop outside the devcontainer.

Reason:

- Codex may run with high autonomy.
- The devcontainer limits filesystem exposure to the mounted repo and container.
- The firewall reduces unexpected egress.
- The repo is still writable because it is bind-mounted, but the rest of the machine is better isolated.

This does not make destructive actions impossible. It only reduces blast radius.

### 3.2 Use `.agents/skills/` for human-invoked Codex workflows

Create Codex Agent Skills for the user-facing workflow:

```txt
.agents/skills/create-prd/SKILL.md
.agents/skills/convert-prd-to-ralph-json/SKILL.md
.agents/skills/review-ralph-prd/SKILL.md
```

Reason:

- Skills give Codex a natural reusable interface.
- This mirrors the older Claude workflow more closely.
- Skills are better for "I want to create a PRD" or "convert this PRD into Ralph JSON".
- Skills reduce the need to manually paste prompt files.

### 3.3 Keep `scripts/ralph-codex/prompts/`

Do not delete the prompt files.

Keep them as canonical detailed source:

```txt
scripts/ralph-codex/prompts/create-prd.md
scripts/ralph-codex/prompts/convert-prd-to-json.md
scripts/ralph-codex/prompts/review-prd.md
scripts/ralph-codex/prompts/run-story.md
```

Reason:

- Prompt files are explicit and easy to diff.
- Scripts can read prompt files directly.
- Skills can reference them instead of duplicating all logic.
- This avoids spreading slightly different instructions across many places.

### 3.4 Do not turn the loop into a skill

Do not create a skill that runs the loop.

Keep the loop controlled by scripts:

```bash
bash scripts/ralph-codex/bin/run-once.sh
bash scripts/ralph-codex/bin/loop.sh 3
```

Reason:

- The loop needs hard controls: exit codes, dirty tree checks, placeholder guard, quality gates, `.last-message`, and bounded iteration count.
- Skills are good for guiding the agent.
- Shell scripts are better for enforcing execution safety.

### 3.5 `AGENTS.md` remains the repository-wide policy

Do not modify `AGENTS.md`.

Reason:

- It already contains project-wide rules.
- It should not contain task-specific Ralph loop instructions.
- Ralph-specific behavior belongs in `scripts/ralph-codex/` and `.agents/skills/`.

---

## 4. Hard rules for this task

- Do not modify product/app code.
- Do not modify database migrations.
- Do not modify `AGENTS.md`.
- Do not run a real Ralph loop.
- Do not replace the existing Ralph scaffold.
- Do not delete `scripts/ralph-codex/prompts/`.
- Do not add secrets.
- Do not add npm dependencies.
- Keep changes limited to:
  - `.agents/skills/**`
  - `.devcontainer/**`
  - `scripts/ralph-codex/**`
  - optionally `.gitignore` only if needed
  - optionally `tasks/finalize-codex-ralph-workflow.md` if saved in repo

---

## 5. Required changes

### 5.1 Create `.agents/skills/create-prd/SKILL.md`

Create:

```txt
.agents/skills/create-prd/SKILL.md
```

Content:

```md
---
name: create-prd
description: Create a product requirements document for the Sr. Reis monorepo without implementing code. Use this when the user asks to plan a feature, write a PRD, or prepare work for Ralph Codex.
---

# Create PRD Skill

You create PRD markdown files for the `sr-reis` monorepo.

## Required reading

Before writing the PRD, read:

1. `AGENTS.md`
2. `scripts/ralph-codex/prompts/create-prd.md`

## Output

Save the PRD under:

```txt
tasks/prd-[feature-name].md
```

Use kebab-case for `[feature-name]`.

## Rules

- Do not implement code.
- Do not modify product files.
- Do not create migrations.
- Ask only essential clarifying questions if the request is too ambiguous.
- If enough context exists, create the PRD directly.
- Follow the structure required by `scripts/ralph-codex/prompts/create-prd.md`.
- Keep each user story small enough for one Ralph Codex iteration.
- For UI stories, include browser verification acceptance criteria.
- For database stories, mention migrations, RLS, and type generation when relevant.

## Final response

After creating the PRD, summarize:

- PRD path
- number of user stories
- main risks/open questions
- recommended next step
```

---

### 5.2 Create `.agents/skills/convert-prd-to-ralph-json/SKILL.md`

Create:

```txt
.agents/skills/convert-prd-to-ralph-json/SKILL.md
```

Content:

```md
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
```

---

### 5.3 Create `.agents/skills/review-ralph-prd/SKILL.md`

Create:

```txt
.agents/skills/review-ralph-prd/SKILL.md
```

Content:

```md
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
```

---

## 6. Update `scripts/ralph-codex/prompts/run-story.md`

Fix the order of operations.

Current risky order says:

```txt
7. Run required checks.
8. Commit all changes for that story.
9. Update the selected story in `prd.json` to `"passes": true`.
10. Append a progress entry to `progress.txt`.
```

Replace with:

```txt
7. Run required checks.
8. Update the selected story in `prd.json` to `"passes": true`.
9. Append a progress entry to `progress.txt`.
10. Commit all changes for that story, including code changes, `prd.json`, and `progress.txt`.
```

Reason:

- `run-once.sh` runs quality checks after Codex returns.
- `run-once.sh` fails if the working tree has uncommitted changes after checks.
- Therefore, `prd.json` and `progress.txt` must be committed together with the story code.

Also add these hard rules:

```md
- Do not leave `prd.json` or `progress.txt` uncommitted after marking a story as passed.
- The final git working tree must be clean.
- Commit code changes, `prd.json`, and `progress.txt` together in the same story commit.
```

Do not otherwise rewrite the prompt.

---

## 7. Update `scripts/ralph-codex/README.md`

Add a section explaining the final workflow.

Required section:

```md
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
```

Add another section:

```md
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
```

Add another section:

```md
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
```

If README already has related sections, merge cleanly instead of duplicating.

---

## 8. Refine `.devcontainer/devcontainer.json`

Current issue:

- Dockerfile installs/configures `zsh`.
- `devcontainer.json` sets VS Code default terminal profile to `fish`.

Since fish is not installed by the Dockerfile, change:

```json
"terminal.integrated.defaultProfile.linux": "fish"
```

to:

```json
"terminal.integrated.defaultProfile.linux": "zsh"
```

Optionally add explicit terminal profiles:

```json
"terminal.integrated.profiles.linux": {
  "bash": {
    "path": "bash",
    "icon": "terminal-bash"
  },
  "zsh": {
    "path": "zsh"
  }
}
```

Do not install fish in this task.

Reason:

- Keep the container simple.
- It already configures zsh.
- Avoid a broken VS Code terminal default.

---

## 9. Refine `.devcontainer/setup-codex.sh`

Current behavior:

```bash
ln -sf "/workspace/.codex/config.toml" "$HOME/.codex/project-config.toml"
```

This is potentially misleading because Codex project config is expected to be loaded from the repository `.codex/config.toml` when the project is trusted. The persistent `$HOME/.codex` volume should mainly hold user/auth/session config.

Update the script to avoid pretending that `project-config.toml` is automatically loaded as normal config.

Preferred behavior:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.codex"

echo "Codex version:"
codex --version || true

echo "Project Codex config:"
if [ -f "/workspace/.codex/config.toml" ]; then
  echo "Found /workspace/.codex/config.toml"
else
  echo "WARN: /workspace/.codex/config.toml not found"
fi

echo "Home Codex config directory:"
echo "$HOME/.codex"

echo "Ralph Codex doctor:"
RALPH_ALLOW_PLACEHOLDER=1 bash /workspace/scripts/ralph-codex/bin/doctor.sh || true

cat <<'EOF'
Codex devcontainer setup complete.

Notes:
- Use /workspace/.codex/config.toml for project-level Codex config.
- Use ~/.codex for authentication/session/user config.
- If Codex asks whether to trust the project, trust this repository before relying on project config.
EOF
```

Do not overwrite `$HOME/.codex/config.toml`.

Reason:

- Avoid clobbering user auth/config.
- Avoid a false assumption that `project-config.toml` is a loaded Codex config file.
- Keep project config versioned at `/workspace/.codex/config.toml`.

---

## 10. Dockerfile considerations

Do not make major Dockerfile changes unless necessary.

Allowed small changes:

- Add `corepack enable` if missing and useful for pnpm.
- Keep `CODEX_VERSION=latest` for now unless the user has specified a version.
- Do not add fish.
- Do not remove zsh.
- Do not remove firewall tools.

If adding Corepack, place it after switching to `USER node` or as appropriate:

```dockerfile
RUN corepack enable
```

Only add this if it builds cleanly in the Dockerfile context.

Reason:

- The monorepo uses pnpm.
- Node images usually include Corepack, but enabling it explicitly can improve reproducibility.

---

## 11. Validation commands

Run these commands after changes.

Do not run a real Ralph loop.

```bash
bash -n .devcontainer/setup-codex.sh
bash -n .devcontainer/init-firewall.sh
bash -n scripts/ralph-codex/bin/doctor.sh
bash -n scripts/ralph-codex/bin/run-once.sh
bash -n scripts/ralph-codex/lib/checks.sh
RALPH_ALLOW_PLACEHOLDER=1 bash scripts/ralph-codex/bin/doctor.sh
```

Also check that no product files changed:

```bash
git status --short
```

Expected changed areas:

```txt
.agents/skills/**
.devcontainer/devcontainer.json
.devcontainer/setup-codex.sh
scripts/ralph-codex/README.md
scripts/ralph-codex/prompts/run-story.md
```

Optional if changed:

```txt
.devcontainer/Dockerfile
```

Unexpected changed areas:

```txt
apps/**
packages/**
supabase/migrations/**
AGENTS.md
```

If unexpected areas changed, revert those changes before finishing.

---

## 12. Acceptance criteria

- [ ] `AGENTS.md` is unchanged.
- [ ] No product/app code changed.
- [ ] No migrations changed.
- [ ] `.agents/skills/create-prd/SKILL.md` exists.
- [ ] `.agents/skills/convert-prd-to-ralph-json/SKILL.md` exists.
- [ ] `.agents/skills/review-ralph-prd/SKILL.md` exists.
- [ ] `scripts/ralph-codex/prompts/` still exists.
- [ ] `scripts/ralph-codex/prompts/run-story.md` commits code + `prd.json` + `progress.txt` together after updating state.
- [ ] `scripts/ralph-codex/README.md` documents devcontainer + skills + final workflow.
- [ ] `.devcontainer/devcontainer.json` uses `zsh`, not `fish`, as terminal default.
- [ ] `.devcontainer/setup-codex.sh` no longer creates `$HOME/.codex/project-config.toml`.
- [ ] `.devcontainer/setup-codex.sh` clearly explains project config vs home config.
- [ ] Validation commands pass, or failures are explained.
- [ ] No real Ralph loop was run.

---

## 13. Suggested commit

```bash
git add .agents .devcontainer scripts/ralph-codex
git commit -m "chore: finalize Codex Ralph workflow"
```

---

## 14. Final response expected from Codex

When done, respond with:

```txt
Summary:
- ...

Files changed:
- ...

Validation:
- command: result
- command: result

Notes:
- ...

Next step:
- Rebuild/open the devcontainer, run RALPH_ALLOW_PLACEHOLDER=1 doctor, then create the first PRD using the create-prd skill.
```
