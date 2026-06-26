# cora-status

Summarise the current state of the vault.

| | |
|---|---|
| **Command** | `/cora-status` |
| **Mode** | Read-only |
| **SKILL.md** | `skills/cora-status/SKILL.md` |

## Triggers

"vault status", "what's in my vault", "what's open", "what's been
happening", "where do things stand", "vault summary".

## Inputs

None.

## Reads / writes

- **Reads:** `projects/_INDEX.md`, each top-level project's
  `ACTIVITY.md` (modules don't have one), `ISSUES.md` and `PROGRESS.md`,
  `ideas/*.md`.
- **Writes:** nothing.

## Output

- Projects table (status, phase, open-issue count).
- Recent activity across projects (newest first).
- Active-idea counts by domain.

## Key rules

- Counts from actual files — no speculation.
- Read-only.
- Single-screen, scannable.
- Missing `current_phase` shows `—`, not "unknown".

## Related

Big-picture counterpart to [cora-find](cora-find.md) (locate something)
and [cora-read](cora-read.md) (read one thing in full).
