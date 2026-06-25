---
name: vault-lint
description: >
  Health-checks RM's memory vault for contradictions, stale claims,
  orphan pages, missing cross-references, and topics mentioned but
  lacking their own page. Read-only — produces a report only, never
  writes. Use when RM asks to lint, audit, check, or health-check the
  vault. Trigger phrases include: "lint the vault", "check the vault",
  "audit my notes", "what's stale", "find orphans", "what's missing",
  "vault health".
---

# Vault Lint

A diagnostic pass over the vault. Produces a structured report so RM
can decide what to fix. Never writes — fixes are RM's call.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1).

---

## Step 2 — Run the checks

Run each check below. For each finding, capture: file path, the issue,
and (where possible) a suggested action.

### Check 1 — Orphan pages

A page is an orphan if no other vault file links to it via `[[...]]`.

Scan all `.md` files under:
- `research/topics/`
- `projects/` (excluding `_TEMPLATE/`)
- `ideas/`

For each candidate, search the rest of the vault for `[[{filename}]]`
or `[[{path}]]`. Note any with zero inbound links.

Exclude: index files (`_INDEX.md`), template files, README files.

### Check 2 — Topics mentioned but missing

Search project files and ideas files for technical concepts that look
like they should be research topics (e.g. "APNs", "Live Activities",
"Play Integrity") but don't have a corresponding
`research/topics/{slug}.md`.

This is fuzzy — flag candidates, don't auto-create.

### Check 3 — Stale topics

A topic is potentially stale if:
- `last_updated` in its frontmatter is >90 days old AND
- Its linked projects have had progress updates more recently (check
  `projects/.../PROGRESS.md` `last_updated`)

This often means the topic page hasn't been updated to reflect
project work that has moved past it.

### Check 4 — Source conflicts left unresolved

Search `research/topics/*.md` for `⚠ Source conflict:` markers.
Report each one — these are open issues the LLM previously flagged
during ingest.

### Check 5 — Open issues missing prevention

Scan `projects/**/ISSUES.md` for resolved issues whose **Prevention**
section is empty, `*(pending)*`, or `*(to be filled in)*`.

These are issues that were fixed but where the lesson wasn't captured.

### Check 6 — ACTIVITY.md health

Every **top-level** project should have an `ACTIVITY.md` feed (it's
scaffolded from the template at creation, even before the project has
any modules). **Modules should never have their own** — their activity
rolls up into the parent's feed instead.

Scan `projects/` (excluding `_TEMPLATE/` and `_archive/`) and flag:
- **Missing feed** — a top-level project folder with `OVERVIEW.md` but
  no `ACTIVITY.md`. Likely predates the template gaining this file, or
  was created without going through `vault-project-init`.
- **Misplaced feed** — a module (a project folder nested under another
  project folder) that has its own `ACTIVITY.md`. It shouldn't — flag
  for removal.
- **Stale feed** — `ACTIVITY.md` whose newest entry (or `last_updated`
  frontmatter) is >60 days old while the project (or any of its modules)
  has more recent `PROGRESS.md` work → activity isn't being recorded.
- **Orphaned breadcrumb** — a `[from {sibling}]` or `[{submodule}]`
  breadcrumb whose `→ [[...]]` target file doesn't resolve (the source
  entry was moved or never written).

### Check 7 — Active Projects table out of sync

Compare the **Active Projects** table in `AGENTS.md` against the
folders in `projects/`. Flag:
- Projects in `AGENTS.md` but no folder in `projects/`
- Folders in `projects/` not listed in `AGENTS.md`
- Statuses in `AGENTS.md` that don't match the project's
  `PROGRESS.md` frontmatter
- **Parent/submodule frontmatter drift** — for each module (a project
  folder nested under another project folder), check its `OVERVIEW.md`
  `parent:` field names the actual parent, and that the parent's
  `OVERVIEW.md` `submodules:` list includes the module back. Flag any
  one-sided declaration (module claims a parent that doesn't list it,
  or a parent lists a submodule whose own `parent:` doesn't match).

### Check 8 — Broken `[[wikilinks]]`

Scan all `.md` files for `[[...]]` links. For each link, check whether
the target file exists. Report broken links.

This catches typos, renamed files, and links to files that were
intended-but-not-yet-created.

### Check 9 — Stale active sessions

Scan `sessions/` (not `sessions/_archive/`). For each session folder
whose `SESSION.md` has `status: active` and a `date:` more than 60
days old, flag for manual archival.

The lint never moves sessions — archival is a manual step. The flag
includes the destination path so RM can drag-and-drop in Obsidian or
run a shell `mv`.

---

## Step 3 — Format the report

Output a single markdown report. Group findings by check. Skip checks
that found nothing — don't pad the report.

```
# Vault Lint Report — YYYY-MM-DD

Scanned {N} files in {duration}.

## 🪴 Orphan Pages ({count})

- `path/to/file.md` — created YYYY-MM-DD, no inbound links
  *Suggested action: link from {likely parent page}*

## 🌱 Missing Topic Pages ({count})

- "APNs internals" mentioned in `agentwatch-push-proxy/ISSUES.md`
  but no `research/topics/apns-...` page exists
  *Suggested action: ingest a source on APNs to create the page*

## 🥀 Stale Topics ({count})

- `topics/apns-push-notifications.md` last updated 2026-03-15;
  linked project `agentwatch-push-proxy` has updates through 2026-06-02
  *Suggested action: re-ingest recent push-proxy work into the topic*

## ⚠ Source Conflicts ({count})

- `topics/{slug}.md` has 1 unresolved conflict between
  `sources/articles/...` and `sources/analyses/...`
  *Suggested action: resolve and update the Summary*

## 🔧 Issues Missing Prevention ({count})

- `agentwatch-desktop/ISSUES.md` [ISSUE-001] resolved 2026-05-12
  *Suggested action: fill in Prevention section*

## 📒 ACTIVITY.md Health ({count})

- `projects/some-standalone-project/` (top-level) has `OVERVIEW.md` but
  no `ACTIVITY.md`
  *Suggested action: scaffold it from the template (predates ACTIVITY.md being added, or wasn't created via vault-project-init)*
- `projects/agentwatch/agentwatch-relay/ACTIVITY.md` exists, but
  `agentwatch-relay` is a module
  *Suggested action: remove it — its activity belongs in the parent's `projects/agentwatch/ACTIVITY.md`*
- `projects/agentwatch/ACTIVITY.md` newest entry 2026-03-15; module
  `agentwatch-relay/PROGRESS.md` has updates through 2026-06-02
  *Suggested action: activity isn't being logged — confirm writes go through vault-logger*

## 📄 Stale Active Sessions ({count})

- `sessions/2026-03-15-some-discussion/` — active, 79 days old
  *Suggested action: move to `sessions/_archive/` and set status: archived*

## 📋 Active Projects Table Drift ({count})

- `agentwatch-protocol` in AGENTS.md but no folder
  in `projects/agentwatch/`
  *Suggested action: create the folder, or remove from table*
- `agentwatch-relay/OVERVIEW.md` has `parent: agentwatch`, but
  `agentwatch/OVERVIEW.md` `submodules:` doesn't list `agentwatch-relay`
  *Suggested action: add it to the parent's submodules list*

## 🔗 Broken Wikilinks ({count})

- `projects/agentwatch/OVERVIEW.md` → `[[agentwatch-protocol/STYLE]]`
  (target does not exist)
  *Suggested action: create file or correct link*

---

Summary: {N} findings across {M} categories.
{If zero findings: "Vault is clean. ✓"}
```

---

## Rules

- **Read-only.** Never write to any vault file from this skill.
- **Group findings by check** — don't interleave categories.
- **Suggest, don't decide.** Every finding gets a "Suggested action"
  line; RM decides what to act on.
- **Skip empty checks** — don't list categories that found nothing.
- **Cap report length.** If a check finds >20 items, show the top 10
  by priority (oldest, most-linked, etc.) and note "{N} more".
- **Always state the scope** at the top (N files scanned, when).
