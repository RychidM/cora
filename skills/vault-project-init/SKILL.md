---
name: vault-project-init
description: >
  Initialises a new project or module in RM's memory vault. Creates the
  project folder structure from the template, registers it in the index
  and AGENTS.md, and optionally syncs agent files to its repo. Use when
  RM asks to create, init, add, or set up a new project or module.
  Trigger phrases include: "init project", "create project", "add a new
  project", "set up a project", "create a module".
---

# Vault Project Init

Creates a new project (top-level or module) in the vault. Mirrors the
behaviour of `scripts/init-project.sh` so this skill works even when the
shell scripts aren't available.

---

## Step 1 — Gather parameters

From the conversation, determine:

| Parameter | Required | Format |
|-----------|----------|--------|
| `name` | yes | kebab-case project name |
| `parent` | only for modules | name of an existing top-level project |
| `repo_path` | optional | absolute path to the project's code repository |

If `parent` is given, this is a module nested under the parent.

If parameters are ambiguous, ask before writing files.

---

## Step 2 — Locate the vault and template

Resolve vault root (see `vault-logger` Step 1).

Template directory: `{vault_root}/projects/_TEMPLATE/`
Required files in the template: `OVERVIEW.md`, `STYLE.md`, `ISSUES.md`,
`PROGRESS.md`. `ACTIVITY.md` may also be present; if it isn't, Step 3
creates one from the skeleton.

If the template doesn't exist, stop and ask RM.

---

## Step 3 — Create the project folder

Determine target path:
- Top-level: `projects/{name}/`
- Module: `projects/{parent}/{name}/`

If the parent doesn't exist when one was specified, stop and ask.

Copy each template file into the target folder. For each `.md` file,
replace placeholders:
- `project: project-name` → `project: {name}`
- `Project Name` → `{name in title case, dashes → spaces}`
- `YYYY-MM-DD` → today's date

If this is a module, prepend to `OVERVIEW.md` after the first heading:

```
---

## System Context

This is a module of **{parent}**.
→ See [[../OVERVIEW]] for the full system architecture and cross-module
decisions.
```

### Create the ACTIVITY.md feed

Every project and module gets an `ACTIVITY.md` so session-start reads and
cross-module breadcrumbs have a target. If the template already supplied
one, use it (with placeholders replaced as above). Otherwise create
`{target_path}/ACTIVITY.md` from this skeleton:

```markdown
---
type: activity
project: {name}
last_updated: {today}
---

# {Project Name} — Activity Feed

> Chronological feed of work touching this project, including cross-module
> breadcrumbs from siblings. Most recent at top.

---
```

Leave it with no entries — the first `vault-logger` write populates it.

---

## Step 4 — Register the project

Update `projects/_INDEX.md`:
- Top-level: insert a new row before any `*(add rows...)*` placeholder
- Module: insert a nested row using `&nbsp;&nbsp;↳ {name}` under the
  parent's section

Row format:
```
| {name or ↳ name} | ⚪ Planned | | {today} | [[{path}/OVERVIEW]] |
```

Update `AGENTS.md`:
- Find the "Active Projects" table
- Insert a row in the same nested format
- Place before any `*(copy ...)*` placeholder

---

## Step 5 — Optionally sync agent files

If `repo_path` is given:
1. Append the path to `{vault_root}/.project-paths` (skip if already there)
2. Invoke `vault-project-sync` (or instruct the user to run it)

---

## Step 6 — Report

```
Initialised project: {name}
  Vault folder: {target_path} (incl. empty ACTIVITY.md)
  Registered in: _INDEX.md, AGENTS.md

Next:
  Fill in {target_path}/OVERVIEW.md
  Run /vault-sync if you haven't already
```

---

## Rules

- **Never overwrite an existing project folder** — if it exists, stop
  and ask
- **Never invent placeholder content** — leave template `*(Fill in)*`
  placeholders alone for RM to complete
- **Module nesting is one level deep** — `projects/{parent}/{module}/`,
  not deeper
