---
name: vault-idea-status
description: >
  Advances an idea's lifecycle status in the vault's ideas files — moving
  it through Raw → Active → Building → Shipped, or to Parked/Dropped — and
  moves it between the active and parked/archived sections as needed. Use
  when RM says an idea has progressed or stalled. Trigger phrases include:
  "mark that idea as building", "the X idea shipped", "park the Y idea",
  "promote that idea to active", "drop that idea", "that idea is done".
  Edits the idea block in place; never logs through review.
---

# Vault Idea Status

Updates the `**Status:**` line on an idea in `ideas/{domain}.md` and, when
the new status warrants, moves the idea block between the file's
`## Active Ideas` and parked/archived sections.

---

## Step 1 — Locate the vault and the idea

Resolve vault root (see `vault-logger` Step 1).

Find the idea RM means across `ideas/*.md` (`technical`, `product`,
`content`, `business`). Match on the idea's `### {title}` and body.

If more than one idea matches, list candidates and ask. If none match,
say so and offer to log a new idea via `vault-logger`.

---

## Step 2 — Determine the new status

Read the file's existing status vocabulary first and match it. If the
file uses no explicit vocabulary, use this default ladder:

| Status | Meaning | Section |
|--------|---------|---------|
| 🌱 Raw | captured, not evaluated | Active Ideas |
| 🔎 Active | being actively considered | Active Ideas |
| 🚧 Building | being built / in progress | Active Ideas |
| 🚀 Shipped | shipped or completed | Shipped / Archived |
| 💤 Parked | set aside, revisit later | Parked |
| 🗑 Dropped | abandoned | Parked / Archived |

Map RM's phrasing to the closest status. If a target section
(`## Shipped`, `## Parked`, `## Archived`) doesn't exist and the new
status needs one, create it at the end of the file.

---

## Step 3 — Confirm if the idea moves sections

- **Status change only** (stays in Active Ideas): apply directly.
- **Status change that moves the block** between sections
  (e.g. Active → Shipped, Active → Parked): show RM what will move, then
  apply.

---

## Step 4 — Apply the change

1. Update the `**Status:**` line on the idea block using a
   uniquely-anchored edit (anchor on the idea's `### {title}` plus the
   status line so it matches exactly once).
2. If the status moves the idea between sections, move the **entire**
   idea block (from its `###` to the next sibling `###` or `##` boundary)
   into the target section, preserving its content verbatim.
3. Optionally add/update a dated line, e.g. `**Shipped:** {today}` or
   `**Parked:** {today}`, matching the file's existing convention.

Preserve everything else in the block — summary, body, wikilinks, dates.

---

## Step 5 — Report

```
Idea "{title}" → {new status}
  ideas/{domain}.md
  {moved to "## Shipped" | updated in place}
```

---

## Rules

- **Match the file's existing status vocabulary** before falling back to
  the default ladder
- **Move the whole block** when changing sections — never split an idea
- **Confirm section moves** — status-only changes can apply directly
- **Preserve content** — only the status line and section placement
  change
- **Never delete an idea** — Dropped ideas move to Parked/Archived, they
  are not removed
