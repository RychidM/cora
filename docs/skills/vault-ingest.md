# vault-ingest

Process a research source into one or more topic synthesis pages.

| | |
|---|---|
| **Command** | `/vault-ingest` |
| **Mode** | Write (creates and updates `research/topics/`; appends to `research/_logs/INGEST_LOG.md`) |
| **SKILL.md** | `skills/vault-ingest/SKILL.md` |

## Triggers

"ingest this", "process this article", "file this source", "integrate this
into the wiki", "add this to topics".

## Inputs

- A source filename in `research/sources/{articles|docs|analyses|notes}/`,
  or "the article I just clipped" (uses the most recently modified file
  under `research/sources/articles/`).

## Reads / writes

- **Reads:** the named source file; existing topic pages it will update;
  `research/_INDEX.md`.
- **Writes:**
  - Creates or updates one or more `research/topics/{slug}.md` pages.
  - Updates the row in `research/_INDEX.md` (count + date).
  - Appends one entry to `research/_logs/INGEST_LOG.md`.
- **Never modifies the source file** — sources are immutable from the
  moment they land.
- **Never edits project files** — project relevance is surfaced in the
  report so RM can choose to log it through `vault-logger`.

## Key rules

- **Always discusses proposed topic targets before writing** (Step 2 of
  the skill). RM stays in control of emphasis.
- **Rewrites Summary sections in full** on every update — the synthesis
  reads as if written in one pass with full knowledge of all sources.
- **Cites every claim** with a `[[../sources/...]]` link.
- **Flags source conflicts explicitly** with `⚠ Source conflict:`
  markers — never silently picks a side.

## Related

[vault-lint](vault-lint.md) — periodic health check; flags source
conflicts, stale topics, and missing topic pages.
[vault-find](vault-find.md), [vault-read](vault-read.md) — discover and
read what's already in the research library.
