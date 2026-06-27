# cora-edit

Make a direct, in-place edit to existing vault content.

| | |
|---|---|
| **Command** | `/cora-edit` |
| **Mode** | Write (gated, transform in place) |
| **SKILL.md** | `skills/cora-edit/SKILL.md` |

## Triggers

"fix the agentwatch overview", "update the style guide", "correct that
issue's description", "reword the brand profile".

## Inputs

What to change — resolved the same way as [cora-read](cora-read.md),
plus the desired change.

## Reads / writes

- **Reads:** the target file.
- **Writes:** a surgical, uniquely-anchored replacement. Traceability
  comes from version history, not a log record.

## Key rules

- **Existing content only** — new knowledge goes through
  [cora-logger](cora-logger.md), which resolves the destination and
  any cross-module breadcrumbs.
- **Gated:** confirms a before → after before non-trivial writes
  (frontmatter, table headers, status fields, `AGENTS.md` / `_INDEX.md` /
  `brand/`).
- Surgical edits — never full-file rewrites for a small fix.
- Preserves frontmatter order, tables, headings, wikilinks, issue IDs.
- Never deletes a project, file, or entry.

## Related

For capturing *new* knowledge with destination + breadcrumb resolution,
use [cora-logger](cora-logger.md). Read first with
[cora-read](cora-read.md).
