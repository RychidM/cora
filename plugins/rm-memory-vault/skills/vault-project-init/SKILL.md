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
`PROGRESS.md`, `ACTIVITY.md`. The template also has a `docs/` folder
(with a placeholder `docs/README.md`) for long-form project documents —
copy it along with the rest of the template.

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

If this is a module:

1. Prepend to `OVERVIEW.md` after the first heading:

   ```
   ---

   ## System Context

   This is a module of **{parent}**.
   → See [[../OVERVIEW]] for the full system architecture and cross-module
   decisions.
   ```

2. **Delete `{target_path}/ACTIVITY.md`.** Modules never get their own —
   their activity rolls up into the parent's feed via `vault-logger`
   breadcrumbs.

3. **Declare the relationship in frontmatter** — this, not folder
   nesting, is what `AGENTS.md` treats as authoritative when resolving
   which `ACTIVITY.md` to read at session start:
   - In the module's `OVERVIEW.md`, set `parent:` (currently empty) to
     `{parent}`.
   - In the **parent's** `OVERVIEW.md`, add `{name}` to `submodules:`
     (e.g. `submodules: []` → `submodules: [{name}]`; if it already has
     entries, append `{name}` rather than replacing the list). Skip if
     `{name}` is already listed.

### Top-level projects keep ACTIVITY.md

Top-level projects keep the `ACTIVITY.md` copied from the template
as-is (placeholders replaced as above) — leave it with no entries. It
stays empty until the project gets its first module and a `vault-logger`
write needs to drop a breadcrumb into it.

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

Top-level:
```
Initialised project: {name}
  Vault folder: {target_path} (incl. empty ACTIVITY.md, docs/)
  Registered in: _INDEX.md, AGENTS.md

Next:
  Fill in {target_path}/OVERVIEW.md
  Drop long-form docs in {target_path}/docs/
  Run /vault-sync if you haven't already
```

Module:
```
Initialised module: {parent}/{name}
  Vault folder: {target_path} (docs/, no ACTIVITY.md)
  Declared: parent: {parent} in {name}/OVERVIEW.md; {name} added to {parent}/OVERVIEW.md submodules
  Registered in: _INDEX.md, AGENTS.md

Next:
  Fill in {target_path}/OVERVIEW.md
  Drop long-form docs in {target_path}/docs/
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
- **Declare parent/submodule relationships in frontmatter, not just
  folder location** — set both sides (`parent:` on the module,
  `submodules:` on the parent) every time a module is created
