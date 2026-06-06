# vault-idea-status

Advance an idea's lifecycle status.

| | |
|---|---|
| **Command** | `/vault-idea` |
| **Mode** | Write (transform in place) |
| **SKILL.md** | `skills/vault-idea-status/SKILL.md` |

## Triggers

"mark that idea as building", "the X idea shipped", "park the Y idea",
"promote that idea to active", "drop that idea".

## Inputs

Which idea, and its new state.

## Reads / writes

- **Reads:** `ideas/*.md`.
- **Writes:** updates the idea block's `**Status:**` line and, when the
  new status warrants, moves the whole block between sections (Active /
  Shipped / Parked / Archived).

## Status ladder (default; matches file's own vocabulary first)

🌱 Raw → 🔎 Active → 🚧 Building → 🚀 Shipped · 💤 Parked · 🗑 Dropped

## Key rules

- Matches the file's existing vocabulary before falling back to the ladder.
- Moves the **entire** block when changing sections — never splits an idea.
- Confirms section moves; status-only changes apply directly.
- Never deletes — Dropped ideas relocate, not removed.

## Related

Lifecycle sibling of [vault-project-status](vault-project-status.md).
Ideas first arrive via [vault-logger](vault-logger.md).
