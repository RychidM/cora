# cora-project-sync

Write per-agent context files into a project repo and install per-agent
`SessionStart` hooks.

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
  OVERVIEW if it's a module), `sessions/_INDEX.md`, and the parent's
  `ACTIVITY.md`.
- **Writes (into the repo):**
  - Agent instruction files: `.claude/CLAUDE.md`, `.gemini/GEMINI.md`,
    `.github/copilot-instructions.md`, `.codex/instructions.md`.
  - SessionStart hook wrappers: `.claude/hooks/cora-session-start.sh`,
    `.codex/hooks/cora-session-start.sh`, `.gemini/hooks/cora-session-start.sh`,
    `.github/hooks/cora-session-start.sh`.
  - Hook configs: `.claude/settings.json`, `.codex/hooks.json`,
    `.gemini/hooks.json`, `.github/hooks/cora-session-start.json`.
  - A `.gitignore` block covering all of the above.

Every generated instruction file starts with a
`MANDATORY SESSION START CONTEXT` block that surfaces the activity recap
since the last session. Hooks do the same dynamically when the agent fires
`SessionStart`.

## Key rules

- One-way: never modifies any vault file.
- Generated files are always gitignored (never committed).
- Always stamps a sync timestamp.
- Quote paths — the Mac vault path contains spaces.
- No matched vault folder → syncs `AGENTS.md` only and says so.
- Existing user hooks (e.g. `.github/hooks/hooks.json`) are left untouched.

## Related

Mirrors `scripts/sync-memory.sh`. Re-run after
[cora-move](cora-move.md) or archiving via
[cora-project-status](cora-project-status.md) — those make synced files
stale.
