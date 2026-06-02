---
name: vault-review
description: >
  Applies RM's review decisions to entries in the pending-review log —
  flipping `[PENDING]` entries to `[APPROVED]`, `[DISCARDED]`, or
  `[DEFER]` from chat, so the review loop can be closed without opening
  Obsidian. Use when RM states a decision about pending entries. Trigger
  phrases include: "approve that entry", "approve all pending", "discard
  the last one", "defer entry 3", "mark these approved", "reject that
  idea", "review the log". Apply only the decisions RM actually states —
  never decide approval on RM's behalf.
---

# Vault Review

Flips the `status:` field on entries in `_logs/PENDING_REVIEW.md`
according to RM's stated decisions. This is the chat-side equivalent of
editing statuses in Obsidian. `vault-promoter` then moves `[APPROVED]`
entries to their destinations.

The agent never decides whether an entry deserves approval — it only
applies the decision RM states. When RM's instruction is broad ("approve
all pending"), confirm the count before writing.

---

## Step 1 — Locate the vault and read the log

Resolve vault root (see `vault-logger` Step 1).

Read `{vault_root}/_logs/PENDING_REVIEW.md` and parse into entries. Each
entry is delimited by `---` lines: a YAML-ish header block, then a
details body, terminated by another `---`.

For each entry capture: `summary`, `status`, `type`, `project`, `date`.

---

## Step 2 — Resolve which entries RM means

Map RM's instruction to specific entries:

| RM says | Target |
|---------|--------|
| "approve the last/latest entry" | most recently dated `[PENDING]` entry |
| "approve entry about X" | the `[PENDING]` entry whose summary/body matches X |
| "approve all pending" | every `[PENDING]` entry |
| "approve the agentwatch ones" | every `[PENDING]` entry with `project: agentwatch` |
| "discard / reject ..." | same matching, target status `[DISCARDED]` |
| "defer ..." | same matching, target status `[DEFER]` |

Only `[PENDING]` entries are eligible. Never re-flip `[PROMOTED]`,
`[DISCARDED]`, or `[APPROVED]` entries unless RM explicitly names one and
asks to change it.

If the match is ambiguous (more than one candidate, or none), list the
candidate summaries and ask which RM means. Do not guess.

---

## Step 3 — Confirm before writing

Show what will change, then write:

```
About to update N entries:
- [PENDING] → [APPROVED]  {summary}
- [PENDING] → [DISCARDED] {summary}
```

- **Single named entry**: apply directly, then report.
- **Broad instruction** ("all pending", a whole project): show the list
  and the new status, and require an explicit confirmation before
  writing when it affects more than 3 entries.

---

## Step 4 — Flip the status (schema-preserving)

Use the same minimal two-line anchor as `vault-promoter`: the `summary:`
line (the unique disambiguator) followed by the `status:` line. Nothing
else.

```
oldText:
summary: <exact entry summary>
status: [PENDING]

newText:
summary: <exact entry summary>
status: [APPROVED]
```

Rules for the flip:
- Keep the `summary:` line byte-identical in `oldText` and `newText`.
- Never include `type:`, `project:`, `domain:`, `date:`, or `agent:` in
  the anchor.
- One flip per edit — never batch multiple status changes into one edit.
- If the tool can't take multi-line patterns, fall back to a
  read-modify-write of the whole file changing only the bracket value.
  Never reorder or delete lines.

---

## Step 5 — Report

```
Reviewed N entries:
  [APPROVED]:  N — {summaries}
  [DISCARDED]: N — {summaries}
  [DEFER]:     N — {summaries}

Run /vault-promote to file the approved entries.
```

If RM approved anything, remind them that promotion is the next step.

---

## Rules

- **Apply only stated decisions** — the agent reviews nothing on its own
- **Only `[PENDING]` entries are eligible** unless RM names an exception
- **Confirm broad changes** (>3 entries) before writing
- **Schema-preserving flips only** — same anchor pattern as the promoter;
  this is the most common point of file corruption if done wrong
- **Never delete entries** — review only changes the `status:` field
- **Don't promote here** — flipping to `[APPROVED]` is the end of this
  skill; `vault-promoter` does the move
