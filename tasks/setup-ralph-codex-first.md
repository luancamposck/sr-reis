# Setup Ralph Codex-first for Sr. Reis

> **Use este arquivo como prompt para o Codex CLI dentro do repo local `sr-reis`.**  
> Caminho sugerido: `tasks/setup-ralph-codex-first.md`

---

## 0. Como executar este prompt

No terminal, dentro da raiz do monorepo `sr-reis`:

```bash
git checkout main
git pull
git checkout -b chore/ralph-codex-first

mkdir -p tasks
# salve este arquivo em:
# tasks/setup-ralph-codex-first.md

codex exec --full-auto -C . < tasks/setup-ralph-codex-first.md
```

Se preferir rodar sem `--full-auto` na primeira vez:

```bash
codex exec -C . < tasks/setup-ralph-codex-first.md
```

---

## 1. Objetivo

Criar um setup **Ralph Codex-first** para o monorepo `sr-reis`.

O objetivo é ter um loop autônomo inspirado no Ralph original, mas desenhado para o **Codex CLI** desde o início, sem depender de `.claude/skills`, `CLAUDE.md`, ou adaptação direta do runner do Claude.

O setup deve permitir este fluxo:

```txt
1. Criar PRD markdown em tasks/
2. Converter PRD markdown para prd.json
3. Rodar um loop Codex que:
   - lê AGENTS.md
   - lê prd.json
   - lê progress.txt
   - escolhe uma user story
   - implementa uma única story
   - roda checks
   - commita
   - marca a story como passes=true
   - registra aprendizados
   - repete até terminar
```

---

## 2. Fontes e links de referência

### Repositórios principais

- Ralph original:  
  https://github.com/snarktank/ralph

- Pull Request com proposta de suporte a Codex no Ralph:  
  https://github.com/snarktank/ralph/pull/34

- Codex CLI oficial:  
  https://github.com/openai/codex

- Repo alvo Sr. Reis:  
  https://github.com/luancamposck/sr-reis

- Experimento anterior no gabinete-neo com Ralph/Codex:  
  https://github.com/luancamposck/gabinete-neo/tree/backup/feat-surveys/scripts/ralph

### Referências importantes do Codex

O Codex carrega config em camadas, incluindo config global do usuário e config local do projeto em `.codex/config.toml`:

- Config loader do Codex:  
  https://github.com/openai/codex/blob/main/codex-rs/config/src/loader/mod.rs

O Codex usa `AGENTS.md` como documentação/instruções de projeto, descobrindo arquivos do project root até o diretório atual:

- AGENTS.md discovery no Codex:  
  https://github.com/openai/codex/blob/main/codex-rs/core/src/agents_md.rs

O Codex CLI é instalado/rodado localmente:

- README oficial:  
  https://github.com/openai/codex/blob/main/README.md

---

## 3. Registro de decisões

### Decisão 1 — Codex-first, não runner universal

Não criar um `ralph.sh --tool amp|claude|codex`.

Criar um setup separado e explícito:

```txt
scripts/ralph-codex/
```

Motivo: o PR #34 do Ralph tentou adicionar Codex ao runner oficial, mas foi fechado porque o mantenedor preferiu manter o core do Ralph tool-agnostic. A adaptação para Codex faz mais sentido como fork/setup específico.

### Decisão 2 — AGENTS.md é regra do repo, não prompt operacional

O repo `sr-reis` já tem um `AGENTS.md` completo.

Não criar, substituir, reformatar ou mover o `AGENTS.md`.

Use o `AGENTS.md` existente como fonte de regras permanentes do projeto.

O prompt operacional do loop Ralph deve ficar em:

```txt
scripts/ralph-codex/prompts/run-story.md
```

### Decisão 3 — `.codex/config.toml` pode ser local ao repo

Pode existir:

```txt
.codex/config.toml
```

na raiz do repo.

O Codex pode carregar config local do projeto em camadas. Mesmo assim:

- o projeto precisa estar trusted no Codex;
- config pessoal/autenticação não deve ser versionada;
- não colocar segredos no config do repo;
- algumas chaves são bloqueadas como config local por segurança.

### Decisão 4 — `prd.json` e `progress.txt` devem ser versionados

O Ralph funciona porque cada iteração do agente começa com contexto limpo, mas recupera memória por:

```txt
git history
scripts/ralph-codex/state/prd.json
scripts/ralph-codex/state/progress.txt
AGENTS.md
```

Portanto, `prd.json` e `progress.txt` devem ser commitados.

Arquivos temporários como `.last-message` não devem ser commitados.

### Decisão 5 — Sr. Reis é monorepo

O projeto `sr-reis` é um monorepo.

Os comandos devem respeitar o `package.json` da raiz e os filtros do pnpm.

Comandos atuais esperados:

```bash
pnpm install
pnpm dev
pnpm build
pnpm lint
pnpm format
pnpm typecheck
pnpm dev:db
pnpm db:stop
pnpm db:reset
```

Não inventar scripts inexistentes.

---

## 4. Regras obrigatórias para esta tarefa

1. Não alterar o `AGENTS.md` existente.
2. Não alterar produto, UI, schema, migrations ou código de aplicação.
3. Não adicionar dependências npm.
4. Não adicionar segredos.
5. Não apagar arquivos existentes.
6. Criar apenas o scaffold do Ralph Codex-first.
7. Usar arquivos shell simples e legíveis.
8. Usar nomes em kebab-case.
9. Scripts devem usar `bash`.
10. Scripts devem começar com:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

---

## 5. Tree recomendada

Criar esta estrutura:

```txt
.
├── .codex/
│   └── config.toml
│
├── scripts/
│   └── ralph-codex/
│       ├── README.md
│       │
│       ├── bin/
│       │   ├── doctor.sh
│       │   ├── loop.sh
│       │   ├── run-once.sh
│       │   ├── archive-run.sh
│       │   └── reset-run.sh
│       │
│       ├── prompts/
│       │   ├── run-story.md
│       │   ├── create-prd.md
│       │   ├── convert-prd-to-json.md
│       │   └── review-prd.md
│       │
│       ├── state/
│       │   ├── prd.json
│       │   └── progress.txt
│       │
│       ├── schemas/
│       │   └── prd.schema.json
│       │
│       ├── templates/
│       │   ├── prd.template.md
│       │   ├── prd.template.json
│       │   └── progress.template.txt
│       │
│       └── lib/
│           ├── codex.sh
│           ├── git.sh
│           ├── checks.sh
│           ├── json.sh
│           └── logging.sh
```

Também atualizar `.gitignore` para ignorar apenas arquivos temporários do Ralph Codex:

```gitignore
# Ralph Codex local runtime
scripts/ralph-codex/state/.last-message
scripts/ralph-codex/state/.last-branch
scripts/ralph-codex/archive/
```

Não ignorar:

```txt
scripts/ralph-codex/state/prd.json
scripts/ralph-codex/state/progress.txt
```

---

## 6. Conteúdo esperado dos arquivos

### 6.1 `.codex/config.toml`

Criar se não existir.

Conteúdo mínimo sugerido:

```toml
[features]
rmcp_client = true

[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "."]
startup_timeout_sec = 30

# Supabase MCP can be enabled later when the project ref is confirmed.
# Keep credentials and secrets out of this file.
#
# [mcp_servers.supabase]
# url = "https://mcp.supabase.com/mcp?project_ref=<project-ref>&read_only=true&features=database%2Cdevelopment%2Cfunctions%2Cstorage%2Cdocs"
# startup_timeout_sec = 30

[mcp_servers.shadcn]
command = "npx"
args = ["shadcn@latest", "mcp"]
startup_timeout_sec = 30
```

Não colocar secrets.

Não configurar provider/model aqui se não for necessário.

---

### 6.2 `scripts/ralph-codex/state/prd.json`

Criar placeholder válido:

```json
{
  "project": "sr-reis",
  "branchName": "ralph/example-feature",
  "description": "Placeholder PRD for Ralph Codex. Replace this file before running a real loop.",
  "userStories": [
    {
      "id": "US-001",
      "title": "Replace placeholder PRD",
      "description": "As a developer, I need to replace the placeholder PRD before running Ralph so that the loop has real work to execute.",
      "acceptanceCriteria": [
        "Replace scripts/ralph-codex/state/prd.json with a real PRD generated from tasks/prd-[feature-name].md",
        "Set every new story passes field to false",
        "Keep each story small enough for one focused Codex iteration"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

### 6.3 `scripts/ralph-codex/state/progress.txt`

Criar:

```txt
# Ralph Codex Progress Log
Started: not started
PRD: placeholder

---

## Codebase Patterns

- Read root AGENTS.md before every iteration.
- This repository is a monorepo. Prefer root pnpm scripts and package filters instead of inventing commands.
- Keep Ralph Codex operational prompts under scripts/ralph-codex/prompts, not in AGENTS.md.

---
```

---

### 6.4 `scripts/ralph-codex/schemas/prd.schema.json`

Criar um JSON Schema simples para validar a estrutura mínima:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Ralph Codex PRD",
  "type": "object",
  "required": ["project", "branchName", "description", "userStories"],
  "properties": {
    "project": {
      "type": "string"
    },
    "branchName": {
      "type": "string"
    },
    "description": {
      "type": "string"
    },
    "userStories": {
      "type": "array",
      "items": {
        "type": "object",
        "required": [
          "id",
          "title",
          "description",
          "acceptanceCriteria",
          "priority",
          "passes"
        ],
        "properties": {
          "id": {
            "type": "string"
          },
          "title": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "acceptanceCriteria": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "priority": {
            "type": "integer"
          },
          "passes": {
            "type": "boolean"
          },
          "notes": {
            "type": "string"
          }
        }
      }
    }
  }
}
```

---

## 7. Scripts

### 7.1 `scripts/ralph-codex/lib/logging.sh`

Criar funções simples:

```bash
#!/usr/bin/env bash

log_info() {
  printf "\033[1;34m[info]\033[0m %s\n" "$*"
}

log_success() {
  printf "\033[1;32m[ok]\033[0m %s\n" "$*"
}

log_warn() {
  printf "\033[1;33m[warn]\033[0m %s\n" "$*"
}

log_error() {
  printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2
}
```

---

### 7.2 `scripts/ralph-codex/lib/json.sh`

```bash
#!/usr/bin/env bash

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
```

---

### 7.3 `scripts/ralph-codex/lib/git.sh`

```bash
#!/usr/bin/env bash

ralph_git_root() {
  git rev-parse --show-toplevel
}

ralph_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

ralph_ensure_branch() {
  local branch_name="$1"

  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    git checkout "$branch_name"
  else
    git checkout -b "$branch_name"
  fi
}

ralph_has_changes() {
  ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]
}
```

---

### 7.4 `scripts/ralph-codex/lib/checks.sh`

```bash
#!/usr/bin/env bash

ralph_default_checks() {
  if [ -f package.json ]; then
    pnpm format
    pnpm lint
    pnpm typecheck
  fi
}
```

---

### 7.5 `scripts/ralph-codex/lib/codex.sh`

Use `codex exec`. Prefer `--output-last-message` if supported.

```bash
#!/usr/bin/env bash

ralph_codex_command() {
  local repo_root="$1"
  local prompt_file="$2"
  local last_message_file="$3"

  : > "$last_message_file"

  local cmd="${CODEX_CMD:-codex exec --full-auto}"

  # shellcheck disable=SC2206
  local cmd_parts=($cmd)

  if codex exec --help 2>/dev/null | grep -q -- "--output-last-message"; then
    "${cmd_parts[@]}" \
      -C "$repo_root" \
      --output-last-message "$last_message_file" \
      < "$prompt_file"
  else
    "${cmd_parts[@]}" \
      -C "$repo_root" \
      < "$prompt_file" | tee "$last_message_file"
  fi
}
```

---

### 7.6 `scripts/ralph-codex/bin/doctor.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/../.." && pwd)"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"

log_info "Checking Ralph Codex environment"

command -v git >/dev/null || { log_error "git is required"; exit 1; }
command -v jq >/dev/null || { log_error "jq is required"; exit 1; }
command -v pnpm >/dev/null || { log_error "pnpm is required"; exit 1; }
command -v codex >/dev/null || { log_error "codex is required"; exit 1; }

[ -f "$REPO_ROOT/AGENTS.md" ] || { log_error "AGENTS.md not found at repo root"; exit 1; }
[ -f "$REPO_ROOT/package.json" ] || { log_error "package.json not found at repo root"; exit 1; }
[ -f "$REPO_ROOT/.codex/config.toml" ] || log_warn ".codex/config.toml not found"
[ -f "$RALPH_DIR/state/prd.json" ] || { log_error "state/prd.json not found"; exit 1; }
[ -f "$RALPH_DIR/state/progress.txt" ] || { log_error "state/progress.txt not found"; exit 1; }

ralph_validate_prd "$RALPH_DIR/state/prd.json" || {
  log_error "state/prd.json has invalid Ralph structure"
  exit 1
}

log_success "Ralph Codex environment looks ready"
```

---

### 7.7 `scripts/ralph-codex/bin/run-once.sh`

This script runs exactly one Ralph/Codex iteration.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/../.." && pwd)"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/git.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/codex.sh"

PRD_FILE="$RALPH_DIR/state/prd.json"
PROGRESS_FILE="$RALPH_DIR/state/progress.txt"
PROMPT_FILE="$RALPH_DIR/prompts/run-story.md"
LAST_MESSAGE_FILE="$RALPH_DIR/state/.last-message"

cd "$REPO_ROOT"

"$RALPH_DIR/bin/doctor.sh"

BRANCH_NAME="$(jq -r '.branchName' "$PRD_FILE")"
NEXT_STORY="$(ralph_next_story "$PRD_FILE")"

if [ -z "$NEXT_STORY" ]; then
  log_success "All stories already pass"
  printf "<promise>COMPLETE</promise>\n"
  exit 0
fi

log_info "Ensuring branch: $BRANCH_NAME"
ralph_ensure_branch "$BRANCH_NAME"

BEFORE_HEAD="$(git rev-parse HEAD)"
BEFORE_PRD_HASH="$(sha256sum "$PRD_FILE" | awk '{print $1}')"
BEFORE_PROGRESS_HASH="$(sha256sum "$PROGRESS_FILE" | awk '{print $1}')"

log_info "Running Codex for next story: $NEXT_STORY"

if ! ralph_codex_command "$REPO_ROOT" "$PROMPT_FILE" "$LAST_MESSAGE_FILE"; then
  log_error "Codex execution failed"
  exit 1
fi

AFTER_HEAD="$(git rev-parse HEAD)"
AFTER_PRD_HASH="$(sha256sum "$PRD_FILE" | awk '{print $1}')"
AFTER_PROGRESS_HASH="$(sha256sum "$PROGRESS_FILE" | awk '{print $1}')"

if [ "$BEFORE_HEAD" = "$AFTER_HEAD" ] && [ "$BEFORE_PRD_HASH" = "$AFTER_PRD_HASH" ]; then
  log_error "Iteration did not create a commit or update prd.json"
  log_error "Refusing to continue silently"
  exit 1
fi

if [ "$BEFORE_PROGRESS_HASH" = "$AFTER_PROGRESS_HASH" ]; then
  log_warn "progress.txt was not updated"
fi

if grep -q "<promise>COMPLETE</promise>" "$LAST_MESSAGE_FILE"; then
  log_success "Codex reported completion"
fi

log_success "One Ralph Codex iteration finished"
```

---

### 7.8 `scripts/ralph-codex/bin/loop.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

MAX_ITERATIONS="${1:-10}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAST_MESSAGE_FILE="$RALPH_DIR/state/.last-message"

# shellcheck source=/dev/null
source "$RALPH_DIR/lib/logging.sh"
# shellcheck source=/dev/null
source "$RALPH_DIR/lib/json.sh"

PRD_FILE="$RALPH_DIR/state/prd.json"

"$RALPH_DIR/bin/doctor.sh"

for i in $(seq 1 "$MAX_ITERATIONS"); do
  log_info "Ralph Codex iteration $i of $MAX_ITERATIONS"

  "$RALPH_DIR/bin/run-once.sh"

  if ralph_all_stories_pass "$PRD_FILE"; then
    log_success "All stories pass"
    printf "<promise>COMPLETE</promise>\n"
    exit 0
  fi

  if [ -f "$LAST_MESSAGE_FILE" ] && grep -q "<promise>COMPLETE</promise>" "$LAST_MESSAGE_FILE"; then
    log_success "Completion signal found"
    exit 0
  fi

  sleep 2
done

log_error "Reached max iterations without completing all stories"
exit 1
```

---

### 7.9 `scripts/ralph-codex/bin/reset-run.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cp "$RALPH_DIR/templates/prd.template.json" "$RALPH_DIR/state/prd.json"
cp "$RALPH_DIR/templates/progress.template.txt" "$RALPH_DIR/state/progress.txt"
rm -f "$RALPH_DIR/state/.last-message"
rm -f "$RALPH_DIR/state/.last-branch"

echo "Ralph Codex state reset"
```

---

### 7.10 `scripts/ralph-codex/bin/archive-run.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PRD_FILE="$RALPH_DIR/state/prd.json"
PROGRESS_FILE="$RALPH_DIR/state/progress.txt"

BRANCH_NAME="$(jq -r '.branchName // "unknown-branch"' "$PRD_FILE" | sed 's|/|-|g')"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE_DIR="$RALPH_DIR/archive/$STAMP-$BRANCH_NAME"

mkdir -p "$ARCHIVE_DIR"

cp "$PRD_FILE" "$ARCHIVE_DIR/prd.json"
cp "$PROGRESS_FILE" "$ARCHIVE_DIR/progress.txt"

echo "Archived Ralph Codex run to $ARCHIVE_DIR"
```

---

## 8. Prompts

### 8.1 `scripts/ralph-codex/prompts/run-story.md`

Criar com este conteúdo:

```md
# Ralph Codex — Run One Story

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
```

---

### 8.2 `scripts/ralph-codex/prompts/create-prd.md`

```md
# Ralph Codex — Create PRD Markdown

You are creating a Product Requirements Document for the `sr-reis` monorepo.

Read `AGENTS.md` first.

Do not implement anything.

Ask only essential clarifying questions if the user's request is ambiguous. If enough context exists, create the PRD directly.

Save the PRD under:

```txt
tasks/prd-[feature-name].md
```

Use kebab-case for the filename.

The PRD must include:

1. Introduction
2. Goals
3. Non-goals
4. User stories
5. Functional requirements
6. Technical considerations
7. Data/security considerations
8. Acceptance criteria
9. Open questions

Each user story must be small enough for one Codex iteration.

For UI stories, include browser verification as an acceptance criterion.
```

---

### 8.3 `scripts/ralph-codex/prompts/convert-prd-to-json.md`

```md
# Ralph Codex — Convert PRD Markdown to Ralph JSON

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
```

---

### 8.4 `scripts/ralph-codex/prompts/review-prd.md`

```md
# Ralph Codex — Review PRD Before Loop

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
```

---

## 9. Templates

### 9.1 `scripts/ralph-codex/templates/prd.template.md`

```md
# PRD: Feature Name

## Introduction

Describe the feature.

## Goals

- Goal 1
- Goal 2

## Non-goals

- Out of scope item

## User Stories

### US-001: Story title

**Description:** As a user, I want something so that I get value.

**Acceptance Criteria:**

- Criterion 1
- Criterion 2
- Typecheck passes

## Functional Requirements

- FR-1: Requirement

## Technical Considerations

- Consideration

## Data and Security Considerations

- Consideration

## Open Questions

- Question
```

---

### 9.2 `scripts/ralph-codex/templates/prd.template.json`

Use the same content as `state/prd.json`.

---

### 9.3 `scripts/ralph-codex/templates/progress.template.txt`

Use the same content as `state/progress.txt`.

---

## 10. README

Criar `scripts/ralph-codex/README.md` explicando:

- O que é o Ralph Codex-first.
- Que ele não depende de Claude.
- Que ele usa `AGENTS.md` como regras de projeto.
- Que prompts operacionais ficam em `scripts/ralph-codex/prompts`.
- Como criar PRD.
- Como converter PRD.
- Como rodar `doctor.sh`.
- Como rodar `run-once.sh`.
- Como rodar `loop.sh`.
- Como resetar e arquivar runs.

Incluir comandos:

```bash
scripts/ralph-codex/bin/doctor.sh
scripts/ralph-codex/bin/run-once.sh
scripts/ralph-codex/bin/loop.sh 10
scripts/ralph-codex/bin/archive-run.sh
scripts/ralph-codex/bin/reset-run.sh
```

---

## 11. Permissões de execução

Após criar os scripts, rodar:

```bash
chmod +x scripts/ralph-codex/bin/*.sh
```

Não precisa dar executable bit nos arquivos de `lib/`.

---

## 12. Validação final

Depois de implementar o scaffold, rodar:

```bash
bash scripts/ralph-codex/bin/doctor.sh
```

Também rodar:

```bash
git status --short
```

Verificar que os arquivos criados são apenas relacionados ao Ralph Codex-first e `.codex/config.toml`/`.gitignore`.

Não rodar `loop.sh` de verdade com o PRD placeholder.

---

## 13. Critérios de aceite

A tarefa está concluída quando:

- [ ] `AGENTS.md` existente não foi modificado.
- [ ] `.codex/config.toml` foi criado sem segredos.
- [ ] `scripts/ralph-codex/` foi criado com a tree proposta.
- [ ] `state/prd.json` é JSON válido.
- [ ] `state/progress.txt` existe.
- [ ] `prompts/run-story.md` contém o contrato operacional do loop.
- [ ] `doctor.sh` passa localmente.
- [ ] scripts em `bin/` têm permissão de execução.
- [ ] `.gitignore` ignora `.last-message`, `.last-branch` e `archive/`.
- [ ] Nenhum código de app/produto foi alterado.
- [ ] Nenhuma migration foi criada.
- [ ] Nenhuma dependência foi adicionada.
- [ ] Commit final usa Conventional Commit.

Commit sugerido:

```bash
git add .codex scripts/ralph-codex .gitignore
git commit -m "chore: add Ralph Codex-first scaffold"
```

---

## 14. Observação final para o Codex

Implement this scaffold carefully and minimally.

Do not start a real Ralph loop.

Do not modify product code.

Do not modify `AGENTS.md`.

If a file already exists, inspect it before editing.
