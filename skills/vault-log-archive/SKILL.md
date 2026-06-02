---
name: vault-log-archive
description: >
  Archives promoted and discarded entries from the pending review log
  into a monthly archive file, keeping PENDING_REVIEW.md clean. Use when
  RM asks to archive, clean up, or compact the log. Trigger phrases
  include: "archive the log", "clean up pending review", "archive
  promoted entries", "compact the log".
---

# Vault Log Archive

Moves `[PROMOTED]` and `[DISCARDED]` entries from
`_logs/PENDING_REVIEW.md` into `_logs/archive/YYYY-MM.md`. Keeps the
review log focused on what still needs RM's attention.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1).

---

## Step 2 — Read the pending review log

Read `{vault_root}/_logs/PENDING_REVIEW.md` and parse into entries.

Identify entries with `status: [PROMOTED]` or `status: [DISCARDED]`.

If there are zero entries to archive, tell RM and stop.

---

## Step 3 — Determine the archive file

Group entries to archive by their `date:` field's year-month
(e.g. `2026-06`). For each group:

- Archive file path: `{vault_root}/_logs/archive/YYYY-MM.md`

Create the directory `_logs/archive/` if it doesn't exist.

If an archive file for that month doesn't exist, create it with this
header:

```
---
purpose: log-archive
month: YYYY-MM
---

# Archived Entries — {Month YYYY}

Entries archived from `_logs/PENDING_REVIEW.md`.
Statuses are preserved as they were at archive time.

---

```

---

## Step 4 — Move entries

For each entry being archived:
1. Read the full entry block (header + details + closing `---`)
2. Append it to the matching month's archive file
3. Remove the same block from `_logs/PENDING_REVIEW.md`

After all entries are processed, write both the archive file(s) and the
trimmed `PENDING_REVIEW.md` back.

**Preservation rules:**
- Don't modify any entry's content during archival
- Preserve all fields exactly as written
- Keep entry order (oldest first within each archive file)

---

## Step 5 — Report

```
Archived N entries from PENDING_REVIEW.md:
  → _logs/archive/2026-06.md: N entries
  → _logs/archive/2026-05.md: N entries

Remaining in PENDING_REVIEW.md:
  [PENDING]: N
  [APPROVED]: N
  [DEFER]: N
```

---

## Rules

- **Only archive `[PROMOTED]` and `[DISCARDED]`** — never `[PENDING]`,
  `[APPROVED]`, or `[DEFER]`
- **Never delete content** — moved, not destroyed
- **One archive file per month** — keeps file sizes manageable
- **If an entry has no `date:` field, ask RM where to put it** — don't
  guess the month
- **Confirm before archiving large batches** (>20 entries) so RM has a
  chance to spot anything unexpected
