---
name: vault-promoter
description: >
  Promotes approved entries from RM's pending-review log to their final
  destinations in the Obsidian memory vault. Use this skill whenever RM
  asks to promote, file, move, or process reviewed/approved entries.
  Trigger phrases include: "promote approved entries", "process the log",
  "promote the approved items", "file these entries", "promote", "run the
  promoter". Do not just acknowledge — actually read the log, move each
  approved entry to the right vault file, and mark it `[PROMOTED]`.
---

# Vault Promoter

Reads `_logs/PENDING_REVIEW.md`, finds entries marked `[APPROVED]`, moves
them to the correct vault files, and marks them `[PROMOTED]`. RM never
has to copy-paste between files.

---

## Step 1 — Locate the vault and read the log

Resolve vault root the same way as `vault-logger` Step 1 — actively read
`$AGENT_MEMORY_VAULT` (run `echo "${AGENT_MEMORY_VAULT:-}"`; the value is
not visible otherwise), then fall back to `list_allowed_directories`
(Filesystem MCP), then `~/obsidian-memory-vault`. Confirm
`_logs/PENDING_REVIEW.md` exists before proceeding; if the vault can't be
located, stop and ask RM rather than guessing.

Read `{vault_root}/_logs/PENDING_REVIEW.md` and parse into entries.
Each entry is delimited by `---` lines: a YAML-ish header block, then
the details body, terminated by another `---`.

For each entry, identify:
- `status` — `[APPROVED]` / `[DISCARDED]` / `[DEFER]` / `[PROMOTED]` /
  `[PENDING]` — found in the `status:` field of the header. Default is
  `[PENDING]` if no `status` field is present.
- `type`, `project`, `domain` (if present), `summary`, `date`, `agent`
- Details body — everything between the closing `---` of the header and
  the next `---` separator

---

## Step 2 — Filter to approved entries only

Process **only** entries marked `[APPROVED]`. Skip everything else.

If there are zero `[APPROVED]` entries, tell RM and stop.

---

## Step 3 — Resolve destination per entry

### Type → destination

| Type | Destination file | Where |
|------|------------------|-------|
| `issue` | `projects/{project}/ISSUES.md` | Append under "Open Issues" with next sequential `[ISSUE-NNN]` ID |
| `resolution` | `projects/{project}/ISSUES.md` | Move the matching open issue block to "Resolved Issues", fill in resolution + prevention |
| `decision` | `projects/{project}/OVERVIEW.md` | Append row to "Key Decisions" table |
| `progress` | `projects/{project}/PROGRESS.md` | Append under current phase |
| `context` | `projects/{project}/OVERVIEW.md` | Append to "Notes" section (create if missing) |
| `idea` | `ideas/{domain}.md` | Prepend under "## Active Ideas" |

### Resolving `{project}` to a folder

Projects may be top-level or modules nested under a parent.

Search order:
1. `projects/{project}/` — top-level
2. `projects/*/{project}/` — module under any parent

Use the first match. Example: `project: agentwatch-desktop` resolves to
`projects/agentwatch/agentwatch-desktop/`.

If `project: general`:
- `idea` → `ideas/{domain}.md` (domain decides the file)
- Other types → skip, report "general-type non-idea entries need a project"

---

## Step 4 — Promote each entry

### CRITICAL: Schema-preserving marker flip

When changing `[APPROVED]` → `[PROMOTED]` in the log, the edit MUST use a
minimal two-line anchor: the `summary:` line followed by the `status:`
line. Nothing else.

**Correct pattern:**

```
oldText:
summary: <exact entry summary>
status: [APPROVED]

newText:
summary: <exact entry summary>
status: [PROMOTED]
```

The `summary:` line is the disambiguating anchor (each entry has a unique
summary) and is kept IDENTICAL in both `oldText` and `newText`.

**Never:**
- Include `type:`, `project:`, `domain:`, `date:`, or `agent:` lines in
  the anchor — those must be left untouched
- Reorder lines
- Use a single-line `status: [APPROVED]` anchor — it can match multiple
  entries in the same file
- Combine multiple marker flips into a single edit

If your edit tool doesn't accept multi-line patterns, fall back to a
read-modify-write of the whole file with only the bracket values changed.
Never delete or reorder lines.

### Per-type transformation

#### `issue`

Read the destination ISSUES.md. Find the highest existing `[ISSUE-NNN]`
across both Open and Resolved sections. New ID = NNN + 1.

Append under "## Open Issues":

```
### [ISSUE-NNN] {summary}

**Date found:** {date}
**Severity:** {infer from details, default Medium}
**Reported by:** {agent}

#### Description
{details body}

#### Root Cause
*(pending investigation)*

#### Resolution
*(pending)*

---
```

#### `resolution`

1. Search the destination ISSUES.md for the issue ID in the entry details
   (e.g. "Resolves [ISSUE-001]"). If no ID, search by keyword against open
   issue summaries.
2. If match found in "Open Issues":
   - **Identify the block boundary.** A block starts at `### [ISSUE-NNN]`
     and ends at the next `### [ISSUE-NNN]` header or the next `##`
     heading (e.g. `## Resolved Issues`) — whichever comes first.
   - Move that entire block (and only that block) to "## Resolved Issues"
   - Fill the "Resolution" section with the resolution details
   - Add a "Date resolved" line with the entry date
   - If prevention measures are mentioned, fill those in too
3. No match found: leave entry `[APPROVED]`, report "couldn't match
   resolution to an open issue".

#### `decision`

Append a row to the "Key Decisions" table in `OVERVIEW.md`:

```
| {summary} | {rationale from details} |
```

(Some Key Decisions tables also have a Date column — match the existing
schema of the destination file. Read the table header first.)

If no Key Decisions table exists, append a new section:

```
## Key Decisions

| Decision | Rationale |
|----------|-----------|
| {summary} | {rationale} |
```

#### `progress`

Locate the "Current Phase" section in `PROGRESS.md`. Add under "✅ Done"
if details indicate completion, "🔄 In Progress" if active. Default to
"✅ Done".

```
- {summary} — {date}
```

If the entry indicates a milestone completion, also update the matching
row in the milestones table at the top of the file.

#### `context`

Append to a "## Notes" section in `OVERVIEW.md`. Create the section if it
doesn't exist (place it before "## External Services" or at the end).

```
- **{date}:** {summary}. {details body}
```

#### `idea`

Prepend under "## Active Ideas" in `ideas/{domain}.md`:

```
### {summary}
**Status:** 🌱 Raw
**Added:** {date}
**Summary:** {one-sentence summary}

{rest of details body}

---
```

Place directly under the `## Active Ideas` header so newest sits at top.

---

## Step 5 — Flip the marker

After each successful destination write, flip the entry's status from
`[APPROVED]` to `[PROMOTED]` using the schema-preserving pattern above.

**Do this immediately after each promotion** — not in a batch at the end.
If a later promotion fails, the entries already moved should still show
as `[PROMOTED]`.

---

## Step 6 — Report

```
Promoted N entries:
- [type/project] summary → file
...

Skipped M entries:
- [reason] summary
```

Concise. No full entry contents in the report.

---

## Rules

- Process only `[APPROVED]` entries
- Never delete entries from `PENDING_REVIEW.md`
- If a destination file doesn't exist, do not create it silently — tell
  RM the project folder seems missing and skip
- For ambiguous cases, leave the entry `[APPROVED]` and explain
- Issue IDs must be sequential within their file — check existing IDs
  across both Open and Resolved sections
- Mark `[APPROVED]` → `[PROMOTED]` immediately after each destination
  write succeeds — not at the end
- Use the schema-preserving marker-flip pattern (Step 4) for every
  status change. This is the most common point of file corruption if
  done wrong.
