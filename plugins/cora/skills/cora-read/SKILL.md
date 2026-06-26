---
name: cora-read
description: >
  Reads and returns the full content of a specific vault file or entry —
  a project's OVERVIEW/STYLE/ISSUES/PROGRESS, an idea, a single issue, a
  brand file, or a log entry. Use when the user wants to see the whole thing,
  not just search snippets. Trigger phrases include: "show me the
  agentwatch overview", "read the style guide", "open ISSUE-003", "what's
  in my product ideas", "pull up the brand profile", "show the full
  entry". Read-only — never writes to the vault.
---

# Vault Read

Returns the full content of a named vault target. Where `cora-find`
returns ranked snippets so the user can locate something, `cora-read` returns
the complete content of one resolved target so the user can act on it.

---

## Step 1 — Locate the vault

Resolve vault root (see `cora-logger` Step 1).

---

## Step 2 — Resolve the target

Map the user's request to a concrete path or sub-block:

| the user asks for | Resolve to |
|-------------|-----------|
| a project file ("agentwatch overview") | `projects/{project}/OVERVIEW.md` (or STYLE/ISSUES/PROGRESS) |
| a module file | `projects/{parent}/{module}/{file}.md` |
| an idea domain ("product ideas") | `ideas/{domain}.md` |
| a single idea ("the X idea") | the `### {title}` block inside the matching `ideas/*.md` |
| a single issue ("ISSUE-003") | the `### [ISSUE-NNN]` block inside the project's `ISSUES.md` |
| a brand file ("brand profile", "aesthetic") | `brand/{file}.md` |
| an activity feed ("agentwatch activity") | `projects/{project}/ACTIVITY.md` |
| the index | `projects/_INDEX.md` or `AGENTS.md` |

Project resolution: try `projects/{name}/` first, then
`projects/*/{name}/` for modules. Use the first match.

If the target is ambiguous (multiple files/blocks match), list the
candidates and ask. If nothing matches, say so and suggest the closest
file the user could browse, or offer to run `cora-find`.

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
  summarise unless the user asks for a summary
- **One resolved target** — if the user clearly wants several files, read each
  and label them; don't merge their content
- **Relative paths** — always show the path relative to the vault root
- **If it doesn't exist, say so** — don't fabricate content
