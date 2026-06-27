# cora-project-init

Scaffold a new project or module from the template.

| | |
|---|---|
| **Command** | `/cora-init` |
| **Mode** | Write (create) |
| **SKILL.md** | `skills/cora-project-init/SKILL.md` |

## Triggers

"init project", "create project", "add a new project", "set up a
project", "create a module".

## Inputs

- `name` — kebab-case (required)
- `parent` — existing top-level project (only for modules)
- `repo_path` — optional, absolute path to the code repo

Argument forms: `/cora-init my-project [repo-path]`,
`/cora-init parent/my-module [repo-path]`.

## Reads / writes

- **Reads:** `projects/_TEMPLATE/` (OVERVIEW, STYLE, ISSUES, PROGRESS,
  ACTIVITY, and `docs/`).
- **Writes:** new `projects/{name}/` (or `projects/{parent}/{name}/`)
  from the template with placeholders filled, and a `docs/` folder for
  long-form project documents; registers rows in `_INDEX.md` and
  `AGENTS.md`; appends `repo_path` to `.project-paths`. Top-level
  projects keep the template's empty `ACTIVITY.md`; modules have it
  deleted (their activity rolls up into the parent's feed instead).
  For modules, also sets `parent:` in the module's `OVERVIEW.md` and
  appends to `submodules:` in the parent's `OVERVIEW.md`.

## Key rules

- Never overwrites an existing project folder.
- Never invents placeholder content — leaves `*(Fill in)*` for the user.
- Top-level projects get `ACTIVITY.md` (empty until a module exists);
  modules never get their own.
- Module nesting is one level deep.
- Modules get a "System Context" block linking the parent OVERVIEW, plus
  `parent:`/`submodules:` frontmatter on both sides of the relationship.

## Related

Mirrors `scripts/init-project.sh`. Follow with
[cora-project-sync](cora-project-sync.md) to wire the repo; reshape
later with [cora-move](cora-move.md).
