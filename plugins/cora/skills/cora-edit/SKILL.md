---
name: cora-edit
description: >
  Makes a direct, in-place edit to existing vault content — a project's
  OVERVIEW/STYLE/ISSUES/PROGRESS, an idea, a brand file, or the index —
  when the user wants a change to existing content applied now rather than
  captured as a new entry via cora-logger. Use when the user asks to edit, fix,
  update, correct, reword, or change something that already exists in the
  vault. Trigger phrases include: "fix the agentwatch overview", "update
  the style guide", "correct that issue's description", "reword the brand
  profile", "change the project status note". Confirm the change before
  writing.
---

# Vault Edit

Applies an in-place edit to existing vault content. Like every vault
write it is **gated**: confirm the exact change with the user before writing.

Use this for corrections and rewordings of content that already exists.
For *new* knowledge, prefer `cora-logger` — it resolves the destination
and any cross-module breadcrumbs for you.

---

## Step 1 — Locate the vault and the target

Resolve vault root (see `cora-logger` Step 1).

Resolve the target file (and sub-block, if any) exactly as `cora-read`
Step 2 does. If ambiguous, ask. If it doesn't exist, stop — this skill
edits existing content only; suggest `cora-project-init` or
`cora-logger` instead.

Read the current content of the target.

---

## Step 2 — Determine the precise change

From the conversation, work out the smallest edit that satisfies the user:
- the exact old text being replaced, and
- the exact new text.

Keep edits surgical. Preserve surrounding structure, headings, tables,
frontmatter, and Obsidian wikilinks. Match the file's existing schema and
formatting conventions (read the nearby lines first).

---

## Step 3 — Confirm before writing (the gate)

Show the user a before → after of just the changed region:

```
Editing projects/agentwatch/STYLE.md

- {old line(s)}
+ {new line(s)}
```

Wait for confirmation before writing when the edit:
- changes more than a few lines, or
- touches frontmatter / a table header / a status field, or
- edits `AGENTS.md`, `projects/_INDEX.md`, or any `brand/` file.

For a tiny, unambiguous fix the user explicitly dictated (e.g. "change the typo
'recieve' to 'receive'"), apply directly and show the result.

---

## Step 4 — Write the edit

Use a minimal, uniquely-anchored replacement (the agent's edit tool with
an `oldText`/`newText` that matches exactly once). Never rewrite the
whole file when a targeted edit will do.

Preservation rules:
- Never delete unrelated content
- Never reorder frontmatter fields
- Keep heading levels and list markers consistent with the file
- Don't touch `[ISSUE-NNN]` IDs or `date:` fields unless the edit is
  specifically about them

---

## Step 5 — Report

```
Edited {relative path}:
  {one-line summary of the change}
```

If the edit substantively changes a **submodule** project file (not a
mere typo/reword) and the user would want siblings or the parent to know,
offer — don't auto-write — to drop an `ACTIVITY.md` breadcrumb via
`cora-logger`. Traceability of the edit itself comes from version
history, not a log entry.

---

## Rules

- **Existing content only** — new knowledge goes through `cora-logger`
- **Confirm before non-trivial writes** — the gate is the review
- **Surgical edits** — smallest change that works; never full-file
  rewrites for a small fix
- **Preserve schema** — frontmatter order, tables, headings, wikilinks,
  issue IDs all stay intact
- **Never delete a project, file, or entry here** — editing is not
  deletion; deletion is out of scope for this skill
