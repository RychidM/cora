# vault-recall

Load recent sessions from `sessions/` back into the current agent context.
The opposite direction from `vault-carry`.

| | |
|---|---|
| **Command** | `/vault-recall` |
| **Mode** | Read-only |
| **SKILL.md** | `skills/vault-recall/SKILL.md` |

## Triggers

"load recent sessions", "recall recent sessions", "pull session
context", "what did I discuss recently", "show me past sessions",
"recall that session".

## Inputs

| Invocation | Behaviour |
|------------|-----------|
| `/vault-recall` | Lists recent sessions for the current project (auto-detected from cwd) |
| `/vault-recall <scope-prefix>` | Filters by explicit scope (prefix match) |
| `/vault-recall full <slug>` | Loads one session completely |
| `... --limit N` | Override default count (3, max 10) |
| `... --include-archived` | Include `sessions/_archive/` |

## Reads / writes

- **Reads:** `sessions/_INDEX.md`, matched session folders'
  `SESSION.md`, and (in full mode) `artifacts/` + `references/`
  contents.
- **Writes:** nothing. Read-only by design.

## Modes

### List mode (default)

Shows compact summaries: 2-3 sentence summary, top 3 key points,
artifact filenames, top 2 open threads, path. Doesn't load file
contents — keeps context lean.

### Full mode (`full <slug>`)

Loads one session completely: `SESSION.md` plus all references. For
artifacts, loads everything if total size ≤50KB; otherwise lists with
sizes and asks which to load.

## Key rules

- **Read-only.** Never modifies the vault.
- **Lean by default.** Full content loads are explicit, not implicit.
- **Confirm large loads.** Artifacts >50KB total prompt for selection.
- **Detection failures ask, don't guess.** If the current project can't
  be inferred (e.g. in Claude desktop), the skill asks rather than
  defaulting to all sessions.
- **Prefix match for scope.** `projects/agentwatch` matches any
  session under that path, including modules.
- **Excludes `_archive/` by default.** Add `--include-archived` to
  include older sessions.

## Related

[vault-resume](vault-resume.md) — the scope-agnostic counterpart: pick up
any session in a fresh chat when you're not working inside a project.
[vault-carry](vault-carry.md) — creates the sessions this skill loads.
[vault-find](vault-find.md), [vault-read](vault-read.md) — general
search and read; `vault-recall` is the sessions-specific version with
scope filtering and lean defaults.
[vault-logger](vault-logger.md) — for promoting a decision from a
loaded session.
[vault-ingest](vault-ingest.md) — for promoting a carried reference
from a loaded session into the research library.
