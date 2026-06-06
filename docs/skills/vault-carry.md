# vault-carry

Capture the working context of a chat session into a dedicated folder
under `sessions/`.

| | |
|---|---|
| **Command** | `/vault-carry` |
| **Mode** | Write (creates `sessions/{date-slug}/` with `SESSION.md`, `artifacts/`, `references/`; updates `sessions/_INDEX.md`) |
| **SKILL.md** | `skills/vault-carry/SKILL.md` |

## Triggers

"carry this session", "save this chat", "capture this session",
"close this out into a session", "carry this to my vault".

## Inputs

Inferred from the conversation. Confirmed with RM in a proposal step
before any files are written:

- `slug` — kebab-case session identifier
- `scope` — single vault path (`projects/X`, `ideas/X`, `brand/X`,
  `research/topics/X`, or `general`)
- `summary` — 2-3 sentences
- `key points`, `artifacts`, `references`, `open threads`

## Reads / writes

- **Reads:** the current conversation context only.
- **Writes:**
  - Creates `sessions/{YYYY-MM-DD}-{slug}/` (never overwrites — appends
    `-2`, `-3` if needed)
  - `SESSION.md` with frontmatter + summary + key points + artifacts +
    references + open threads
  - `artifacts/{NN}-{slug}.{ext}` for each artifact saved (sequential
    numeric prefix for stable ordering)
  - `references/{slug}.{ext}` for each external piece of content
    carried (links-only references stay as links in `SESSION.md`)
  - Appends a row to `sessions/_INDEX.md`
- **Never modifies** project files, source files in `research/sources/`,
  or any existing session.

## Key rules

- **Discusses before writing** (Step 3) — RM controls slug, scope, and
  what counts as artifact vs. reference.
- **Single scope per session.** No multi-scope lists.
- **One folder per session**, never flat files.
- **No auto-promotion.** A decision in a session doesn't auto-log; an
  article in references/ doesn't auto-ingest. Surface candidates,
  let RM decide.
- **Never overwrites** an existing session folder.
- **`status: active`** until manually moved to `sessions/_archive/`.

## Related

[vault-lint](vault-lint.md) — flags stale active sessions (>60 days)
for manual archival.
[vault-find](vault-find.md), [vault-read](vault-read.md) — discover and
read past sessions.
[vault-logger](vault-logger.md) — for promoting a single decision from a
session into the pending review log.
[vault-ingest](vault-ingest.md) — for promoting a carried reference into
the long-term research library.
