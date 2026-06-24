# vault-project-init

Scaffold a new project or module from the template.

| | |
|---|---|
| **Command** | `/vault-init` |
| **Mode** | Write (create) |
| **SKILL.md** | `skills/vault-project-init/SKILL.md` |

## Triggers

"init project", "create project", "add a new project", "set up a
project", "create a module".

## Inputs

- `name` — kebab-case (required)
- `parent` — existing top-level project (only for modules)
- `repo_path` — optional, absolute path to the code repo

Argument forms: `/vault-init my-project [repo-path]`,
`/vault-init parent/my-module [repo-path]`.

## Reads / writes

- **Reads:** `projects/_TEMPLATE/` (OVERVIEW, STYLE, ISSUES, PROGRESS,
  ACTIVITY if present, and `docs/`).
- **Writes:** new `projects/{name}/` (or `projects/{parent}/{name}/`)
  from the template with placeholders filled — including an empty
  `ACTIVITY.md` feed (created from the skeleton if the template lacks
  one) and a `docs/` folder for long-form project documents; registers
  rows in `_INDEX.md` and `AGENTS.md`; appends `repo_path` to
  `.project-paths`.

## Key rules

- Never overwrites an existing project folder.
- Never invents placeholder content — leaves `*(Fill in)*` for RM.
- Always creates an `ACTIVITY.md` so session-start reads and breadcrumbs
  have a target; leaves it empty for the first `vault-logger` write.
- Module nesting is one level deep.
- Modules get a "System Context" block linking the parent OVERVIEW.

## Related

Mirrors `scripts/init-project.sh`. Follow with
[vault-project-sync](vault-project-sync.md) to wire the repo; reshape
later with [vault-move](vault-move.md).
