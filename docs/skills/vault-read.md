# vault-read

Return the full content of one resolved file or entry.

| | |
|---|---|
| **Command** | `/vault-read` |
| **Mode** | Read-only |
| **SKILL.md** | `skills/vault-read/SKILL.md` |

## Triggers

"show me the agentwatch overview", "read the style guide", "open
ISSUE-003", "what's in my product ideas", "pull up the brand profile",
"show the full entry".

## Inputs

What to read — a project file, idea domain, single idea, single issue,
brand file, activity feed, or index.

## Reads / writes

- **Reads:** the one resolved target (project files incl. `ACTIVITY.md`,
  `ideas/*.md`, `brand/*.md`, `_INDEX.md`, `AGENTS.md`).
- **Writes:** nothing.

## Output

- Whole file → full verbatim content with its relative path as a header.
- Single block (one issue/idea/log entry) → just that block.
- Very long files → requested section, with an offer to show the rest.

## Key rules

- Read-only and verbatim — no paraphrase unless asked.
- One resolved target; ambiguity → list candidates and ask.
- Doesn't fabricate missing content.

## Related

The full-content complement to [vault-find](vault-find.md)'s snippets.
Pair with [vault-edit](vault-edit.md) when you want to change what you
read.
