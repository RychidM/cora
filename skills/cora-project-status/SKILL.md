---
name: cora-project-status
description: >
  Sets a project's lifecycle status in the vault and keeps the index and
  AGENTS.md in sync — including archiving a finished or abandoned project.
  Use when the user says a project changed state. Trigger phrases include:
  "mark agentwatch active", "set this project to paused", "agentwatch
  shipped", "archive the foo project", "this project is done", "reactivate
  bar". Updates status rows in place; archiving relocates the project
  folder without deleting it.
---

# Vault Project Status

Updates a project's status in three places that must stay consistent —
the project's own `PROGRESS.md` frontmatter, `projects/_INDEX.md`, and the
Active Projects table in `AGENTS.md` — and, when archiving, moves the
project folder out of the active set without destroying it.

---

## Step 1 — Locate the vault and the project

Resolve vault root (see `cora-logger` Step 1).

Resolve the project folder (same as the promoter): `projects/{name}/`
first, then `projects/*/{name}/` for modules. Use the first match. If
none, stop and tell the user the project isn't in the vault.

---

## Step 2 — Determine the new status

Read the existing status vocabulary in `_INDEX.md` / `AGENTS.md` and match
it. If there's no explicit vocabulary, use this default:

| Status | Meaning |
|--------|---------|
| ⚪ Planned | created, not started |
| 🟢 Active | in active development |
| 🟡 Paused | temporarily on hold |
| ✅ Shipped | shipped / done, still listed |
| 📦 Archived | retired; folder moved to `projects/_archive/` |

Map the user's phrasing to the closest status.

---

## Step 3 — Apply a status change (non-archive)

For `Planned` / `Active` / `Paused` / `Shipped`:

1. **`PROGRESS.md`** — update the `current_phase` / status field in
   frontmatter if present (match the file's schema; uniquely-anchored
   edit).
2. **`projects/_INDEX.md`** — update the status cell in the project's row.
   Anchor on the project name (or `↳ {name}` for a module) so the edit
   matches exactly once.
3. **`AGENTS.md`** — update the same project's status cell in the Active
   Projects table.

Keep table columns and frontmatter field order intact. Optionally add a
dated note to `PROGRESS.md` (e.g. under the current phase) recording the
transition, matching the file's convention.

---

## Step 4 — Archiving (📦 Archived)

Archiving is a relocation, never a deletion. Confirm with the user before
moving, then:

1. Create `projects/_archive/` if it doesn't exist.
2. Move the project folder from `projects/{name}/` (or its module path) to
   `projects/_archive/{name}/`, preserving all contents.
3. In `_INDEX.md`: change the row's status to `📦 Archived` and update its
   `[[link]]` to the new `_archive/{name}/OVERVIEW` path — or move the row
   into an `## Archived` section if the index has one.
4. In `AGENTS.md`: remove the project's row from the **Active Projects**
   table (it's no longer active). Don't delete it from the index.
5. Note that any synced repo agent files (CLAUDE.md, etc.) are now stale;
   mention this so the user can re-run or stop syncing.

If the move can't be done with available tools (no shell/move), tell the user
the exact source and destination paths and stop — don't half-apply.

---

## Step 5 — Report

```
Project "{name}" → {new status}
  Updated: PROGRESS.md, _INDEX.md, AGENTS.md
  {Archived: moved to projects/_archive/{name}/}
```

If archived, remind the user that repo agent files for that project are now
stale.

---

## Rules

- **Match the existing status vocabulary** before using the default set
- **Keep all three sources consistent** — PROGRESS.md, _INDEX.md, AGENTS.md
- **Archiving moves, never deletes** — relocate to `projects/_archive/`,
  keep the index entry
- **Confirm before archiving** — it relocates a folder and removes the
  active row
- **Uniquely-anchored edits** — anchor on the project name so a status
  cell in a multi-row table matches exactly once
- **Don't silently leave sources out of sync** — if one can't be updated,
  report which and why
