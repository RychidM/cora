# vault-lint

Diagnostic pass over the vault — surfaces drift, orphans, stale topics,
and other rot that accumulates as the vault grows.

| | |
|---|---|
| **Command** | `/vault-lint` |
| **Mode** | Read-only (produces a report; never writes) |
| **SKILL.md** | `skills/vault-lint/SKILL.md` |

## Triggers

"lint the vault", "check the vault", "audit my notes", "what's stale",
"find orphans", "what's missing", "vault health".

## Inputs

None required. Optional focus argument scopes the report to one check:

- `/vault-lint orphans` — only the orphan-pages check
- `/vault-lint stale` — only the stale-topics check
- `/vault-lint drift` — only the AGENTS.md projects-table check

## Reads / writes

- **Reads:** `AGENTS.md`, every `.md` under `projects/` (incl.
  `ACTIVITY.md`), `research/topics/`, and `ideas/`, plus
  `research/_logs/INGEST_LOG.md`.
- **Writes:** nothing. Fixes are RM's call.

## Checks it runs

1. **Orphan pages** — topic, project, and idea pages with zero inbound
   `[[wikilinks]]`.
2. **Missing topic pages** — concepts mentioned in projects/ideas that
   look like they should have a `research/topics/{slug}.md` page.
3. **Stale topics** — topic pages older than 90 days whose linked
   projects have moved on without re-ingestion.
4. **Source conflicts** — `⚠ Source conflict:` markers left unresolved
   in topic pages.
5. **Issues missing prevention** — resolved issues whose Prevention
   section is empty.
6. **ACTIVITY.md health** — active projects/modules missing an
   `ACTIVITY.md`, feeds gone stale while the project moves on, or
   breadcrumbs whose link targets don't resolve.
7. **Active Projects table drift** — `AGENTS.md` vs. `projects/` folders
   out of sync.
8. **Broken wikilinks** — `[[...]]` pointing at files that don't exist.
9. **Stale active sessions** — sessions in `sessions/` with `status: active`
   and a `date:` more than 60 days old; flagged for manual archival.

## Key rules

- **Read-only.** Never modifies any file.
- **Skips empty checks** — categories with zero findings are omitted
  from the report, no padding.
- **Every finding has a Suggested action line** — RM still decides.
- **Caps long lists** — checks finding >20 items show the top 10 and
  note how many more.

## Related

[vault-ingest](vault-ingest.md) — produces the topic pages this lint
checks for staleness and conflicts.
[vault-carry](vault-carry.md) — produces the sessions this lint checks
for staleness.
[vault-status](vault-status.md) — lighter-weight read of current vault
state (counts, not diagnostics).
