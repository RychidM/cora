---
name: vault-edit
description: >
  Makes a direct, in-place edit to existing vault content — a project's
  OVERVIEW/STYLE/ISSUES/PROGRESS, an idea, a brand file, or the index —
  when RM wants a change applied now rather than routed through the
  pending-review log. Use when RM asks to edit, fix, update, correct,
  reword, or change something that already exists in the vault. Trigger
  phrases include: "fix the agentwatch overview", "update the style
  guide", "correct that issue's description", "reword the brand profile",
  "change the project status note". Confirm the change before writing and
  record it in the log.
---

# Vault Edit

Applies an in-place edit to existing vault content. This deliberately
bypasses the `logger → review → promote` loop, so it is **gated**:
confirm the exact change with RM before writing, and drop a `context`
record into the log so the edit is traceable.

Use this for corrections and rewordings of content that already exists.
For *new* knowledge, prefer `vault-logger` so it goes through review.

---

## Step 1 — Locate the vault and the target

Resolve vault root (see `vault-logger` Step 1).

Resolve the target file (and sub-block, if any) exactly as `vault-read`
Step 2 does. If ambiguous, ask. If it doesn't exist, stop — this skill
edits existing content only; suggest `vault-project-init` or
`vault-logger` instead.

Read the current content of the target.

---

## Step 2 — Determine the precise change

From the conversation, work out the smallest edit that satisfies RM:
- the exact old text being replaced, and
- the exact new text.

Keep edits surgical. Preserve surrounding structure, headings, tables,
frontmatter, and Obsidian wikilinks. Match the file's existing schema and
formatting conventions (read the nearby lines first).

---

## Step 3 — Confirm before writing (the gate)

Show RM a before → after of just the changed region:

```
Editing projects/agentwatch/STYLE.md

- {old line(s)}
+ {new line(s)}
```

Wait for confirmation before writing when the edit:
- changes more than a few lines, or
- touches frontmatter / a table header / a status field, or
- edits `AGENTS.md`, `projects/_INDEX.md`, or any `brand/` file.

For a tiny, unambiguous fix RM explicitly dictated (e.g. "change the typo
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
- Don't touch `[ISSUE-NNN]` IDs, `date:` fields, or `[PROMOTED]` markers
  unless the edit is specifically about them

---

## Step 5 — Record the edit in the log

After a successful write, append a `context` entry to
`_logs/PENDING_REVIEW.md` (via the `vault-logger` format) so the edit is
traceable:

```
---
date: {today}
agent: {agent id}
project: {project or general}
type: context
status: [PROMOTED]
summary: Edited {relative path} — {one-line description of the change}
---

Direct edit applied via vault-edit. {what changed and why, briefly.}

---
```

Mark it `[PROMOTED]` (not `[PENDING]`) — it's a record of an already-
applied change, not something awaiting review. If RM says "don't log
this", skip the record.

---

## Step 6 — Report

```
Edited {relative path}:
  {one-line summary of the change}
  Logged a context record.
```

---

## Rules

- **Existing content only** — new knowledge goes through `vault-logger`
- **Confirm before non-trivial writes** — this skill bypasses review, so
  the gate matters
- **Surgical edits** — smallest change that works; never full-file
  rewrites for a small fix
- **Preserve schema** — frontmatter order, tables, headings, wikilinks,
  issue IDs all stay intact
- **Log the edit** as a `[PROMOTED]` context record unless RM opts out
- **Never delete a project, file, or entry here** — editing is not
  deletion; deletion is out of scope for this skill
