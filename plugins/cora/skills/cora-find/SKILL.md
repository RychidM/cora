---
name: cora-find
description: >
  Searches the user's memory vault for entries by keyword or topic. Returns a
  concise list of matches with their file paths and relevant snippets.
  Use when the user asks to find, search, look up, or recall something from
  the vault. Trigger phrases include: "find in vault", "search vault",
  "look up X in my notes", "what did I note about X", "find issue", "do
  I have an idea about X".
---

# Vault Find

A simple search across the vault. Returns matches grouped by section
(projects, ideas, brand) so the user can navigate quickly.

---

## Step 1 — Get the query

From the conversation, extract the search query. If ambiguous, ask:

> "Search for what — a project name, an issue keyword, an idea topic?"

---

## Step 2 — Locate the vault

Resolve vault root (see `cora-logger` Step 1).

---

## Step 3 — Search

Search the following directories for the query (case-insensitive
substring match across both filenames and file contents):

| Section | Path |
|---------|------|
| Projects | `projects/**/*.md` (incl. `ACTIVITY.md`) |
| Ideas | `ideas/*.md` |
| Brand | `brand/*.md` |
| Research | `research/topics/*.md`, `research/sources/**/*.md` |

Use a shell `grep -ri` if available, or recursive file reads otherwise.

For each match, capture:
- Relative file path
- Section/heading the match appears under (look for the nearest
  preceding `###` or `##` heading)
- A snippet (the line with the match, optionally ±1 line of context)

---

## Step 4 — Rank and format results

Rank matches by:
1. Filename match > content match
2. Match in a heading > match in body text
3. Open issues > resolved issues
4. Recent (by file date or entry `date:` field) > older

Format as:

```
Found N matches for "{query}":

## Projects
- **projects/agentwatch/agentwatch-relay/ISSUES.md** — [ISSUE-001] {summary}
  > {snippet}
- **projects/agentwatch/OVERVIEW.md** — Pairing Flow
  > {snippet}

## Ideas
- **ideas/technical.md** — {idea title}
  > {snippet}

## Brand
- (none)

## Research
- **research/topics/{slug}.md** — {heading}
  > {snippet}
```

Cap at 10 results unless the user asks for more.

If no matches, say so plainly and suggest the closest related sections
the user could browse.

---

## Rules

- **Don't write to the vault** — read-only skill
- **Don't paraphrase the source content** — show actual snippets so the user
  knows what's there
- **Show file paths as relative to the vault root** — for clickable
  navigation in editors that support it
- **For multi-word queries, do both AND (all words) and OR (any word)** —
  show AND matches first, then OR matches if AND returns few results
