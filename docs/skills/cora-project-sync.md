# cora-project-sync

Write per-agent context files into a project repo.

| | |
|---|---|
| **Command** | `/cora-sync` |
| **Mode** | Write (vault → repo, one-way) |
| **SKILL.md** | `skills/cora-project-sync/SKILL.md` |

## Triggers

"sync vault", "sync this project", "refresh agent files", "update
CLAUDE.md", "regenerate agent context".

## Inputs

The target repo — named project (path from `.project-paths`) or the
current working directory.

## Reads / writes

- **Reads:** `AGENTS.md`, the matched project's `OVERVIEW.md` (and parent
  OVERVIEW if it's a module).
- **Writes (into the repo):** `CLAUDE.md`, `GEMINI.md`,
  `.github/copilot-instructions.md`, `.codex/instructions.md`, and a
  `.gitignore` block covering them.

## Key rules

- One-way: never modifies any vault file.
- Generated files are always gitignored (never committed).
- Always stamps a sync timestamp.
- Quote paths — the Mac vault path contains spaces.
- No matched vault folder → syncs `AGENTS.md` only and says so.

## Related

Mirrors `scripts/sync-memory.sh`. Re-run after
[cora-move](cora-move.md) or archiving via
[cora-project-status](cora-project-status.md) — those make synced files
stale.
