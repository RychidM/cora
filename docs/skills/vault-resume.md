# vault-resume

Pick up a past session inside a fresh chat, with no project context
assumed — the scope-agnostic counterpart to `vault-recall`.

| | |
|---|---|
| **Command** | `/vault-resume` |
| **Mode** | Read-only (loads session content into agent context; never writes) |
| **SKILL.md** | `skills/vault-resume/SKILL.md` |

## Triggers

"resume a session", "pick up where I left off", "reopen a session",
"continue a past session", "load a session here", "what was I working on".

## Invocations

- `/vault-resume` — **browse**: list the most recent sessions across all
  scopes, then load the one RM picks in full
- `/vault-resume <query>` — **match**: match by slug or keyword; load
  directly if unique, else list candidates
- `--limit N` — how many browse mode lists (default 5, max 15)
- `--include-archived` — include `sessions/_archive/`

## Reads / writes

- **Reads:** `sessions/_INDEX.md`, the chosen session's `SESSION.md`,
  and its `artifacts/` + `references/` (full load once a session is
  picked).
- **Writes:** nothing. Read-only.

## Key rules

- **No scope assumption.** Resume never auto-detects a project or filters
  by scope — that distinguishes it from `vault-recall`. Browse spans
  every scope so it works from a blank chat.
- **Browse, then load.** Default lists recent sessions and waits for RM
  to pick before loading anything.
- **Full load by default** once chosen — the point is to continue the
  work, not preview it. Surfaces the session's open threads as the
  "pick up" footer.
- **Large loads ask first.** Artifacts + references over 50KB total are
  listed for opt-in rather than auto-loaded.
- **Archive boundary.** Excludes `sessions/_archive/` unless
  `--include-archived`.
- **No auto-promotion.** Suggests logging decisions / ingesting
  references; never does it automatically.

## Related

[vault-recall](vault-recall.md) — the project-bound counterpart that
filters sessions to the current project's scope.
[vault-carry](vault-carry.md) — writes sessions out; resume reads them
back into any chat.
[vault-find](vault-find.md), [vault-read](vault-read.md) — discover and
read past sessions.
[vault-logger](vault-logger.md), [vault-ingest](vault-ingest.md) — for
promoting a decision or reference out of a resumed session.
