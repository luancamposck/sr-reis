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
