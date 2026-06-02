---
name: vault-read
description: >
  Reads and returns the full content of a specific vault file or entry —
  a project's OVERVIEW/STYLE/ISSUES/PROGRESS, an idea, a single issue, a
  brand file, or a log entry. Use when RM wants to see the whole thing,
  not just search snippets. Trigger phrases include: "show me the
  agentwatch overview", "read the style guide", "open ISSUE-003", "what's
  in my product ideas", "pull up the brand profile", "show the full
  entry". Read-only — never writes to the vault.
---

# Vault Read

Returns the full content of a named vault target. Where `vault-find`
returns ranked snippets so RM can locate something, `vault-read` returns
the complete content of one resolved target so RM can act on it.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1).

---

## Step 2 — Resolve the target

Map RM's request to a concrete path or sub-block:

| RM asks for | Resolve to |
|-------------|-----------|
| a project file ("agentwatch overview") | `projects/{project}/OVERVIEW.md` (or STYLE/ISSUES/PROGRESS) |
| a module file | `projects/{parent}/{module}/{file}.md` |
| an idea domain ("product ideas") | `ideas/{domain}.md` |
| a single idea ("the X idea") | the `### {title}` block inside the matching `ideas/*.md` |
| a single issue ("ISSUE-003") | the `### [ISSUE-NNN]` block inside the project's `ISSUES.md` |
| a brand file ("brand profile", "aesthetic") | `brand/{file}.md` |
| a log entry ("the latest log entry") | the matching block in `_logs/PENDING_REVIEW.md` |
| the index | `projects/_INDEX.md` or `AGENTS.md` |

Project resolution (same as the promoter): try `projects/{name}/` first,
then `projects/*/{name}/` for modules. Use the first match.

If the target is ambiguous (multiple files/blocks match), list the
candidates and ask. If nothing matches, say so and suggest the closest
file RM could browse, or offer to run `vault-find`.

---

## Step 3 — Return the content

- **Whole file**: return the full file content verbatim, with the
  relative path as a header.
- **Single block** (one issue, one idea, one log entry): return just that
  block — from its `###`/`---` start to the next sibling boundary.

Show the relative path so it's clickable in editors:

```
## projects/agentwatch/OVERVIEW.md

{full verbatim content}
```

For very long files (>~400 lines), show the requested section and offer
to show the rest, rather than dumping everything.

---

## Rules

- **Read-only** — never write, never modify
- **Verbatim** — return source content as-is; don't paraphrase or
  summarise unless RM asks for a summary
- **One resolved target** — if RM clearly wants several files, read each
  and label them; don't merge their content
- **Relative paths** — always show the path relative to the vault root
- **If it doesn't exist, say so** — don't fabricate content
