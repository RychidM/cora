---
name: vault-logger
description: >
  Logs ideas, decisions, issues, progress updates, and context from the
  current conversation to RM's Obsidian memory vault. Use this skill
  whenever RM asks to log, save, capture, note, remember, or write
  something to the vault. Trigger phrases include: "log this", "save
  this to my vault", "add this to my memory", "note this down", "remember
  this", "log it", "save it", or any variation. Always use this skill
  and actually write the entry — do not just acknowledge or summarise.
---

# Vault Logger

Appends a structured entry to `_logs/PENDING_REVIEW.md` in RM's memory
vault. RM reviews and marks each entry, and `vault-promoter` moves
approved entries to their destinations.

---

## Step 1 — Locate the vault

You must actively resolve the vault root — do not assume a path. Reading
the `$AGENT_MEMORY_VAULT` env var requires running a command; the value is
not visible to you otherwise. Resolve in this order and stop at the first
hit:

1. **Env var (Claude Code / any agent with a shell).** Run:

   ```bash
   echo "${AGENT_MEMORY_VAULT:-}"
   ```

   If it prints a non-empty path, that is the vault root.

2. **Filesystem MCP (Claude desktop, no shell).** Call
   `list_allowed_directories` and pick the allowed directory that
   contains `_logs/PENDING_REVIEW.md`.

3. **Default.** `~/obsidian-memory-vault`.

Before using the resolved root, confirm `{vault_root}/_logs/PENDING_REVIEW.md`
exists. If none of the above yields a valid vault, stop and tell RM the
vault could not be located — ask them to set `AGENT_MEMORY_VAULT` (and, for
Claude desktop, add the vault to the Filesystem MCP allowed directories)
rather than writing to a guessed path.

The log path is `{vault_root}/_logs/PENDING_REVIEW.md`.

---

## Step 2 — Determine entry metadata

Infer from the conversation. Ask only if genuinely ambiguous.

### `type` — what kind of entry is this?

| Type | When to use |
|------|-------------|
| `idea` | A new concept, product idea, feature idea, or thing to explore |
| `decision` | A choice that was made and should be remembered |
| `issue` | A bug, problem, or blocker that was identified |
| `resolution` | How an issue was fixed |
| `progress` | Work completed or a milestone reached |
| `context` | Background information, notes, or facts worth persisting |

### `project` — which project does this relate to?

Use the exact project name from the vault (e.g. `agentwatch`,
`agentwatch-desktop`). Use `general` if it applies across projects or
to no specific project.

If genuinely unclear, ask before writing.

### `domain` — required only for `type: idea`

| Domain | Maps to |
|--------|---------|
| `technical` | `ideas/technical.md` — engineering, infra, tooling, automation |
| `product` | `ideas/product.md` — products, features, apps, ventures |
| `content` | `ideas/content.md` — articles, posts, talks, documentation |
| `business` | `ideas/business.md` — client work, services, offerings |

Omit `domain` for any non-idea type.

### `summary` — one line

The single most important thing about this entry. Be specific.
- Bad: "Discussed auth approach"
- Good: "Decided relay JWT and mobile pairing are separate auth systems"

---

## Step 3 — Format the entry

```
---
date: YYYY-MM-DD
agent: claude-code | claude-desktop | gemini | copilot | codex | other
project: [project-name or general]
type: [idea | decision | issue | resolution | progress | context]
domain: [technical | product | content | business]   ← only when type: idea
status: [PENDING]
summary: [one-line description]
---

[Details — specific and concise. Include file names, URLs, code snippets,
or references to other vault entries where relevant. Write as if the
reader has no memory of this conversation.]

---
```

Use today's date. Use the actual agent ID — `claude-code` in Claude Code,
`claude-desktop` in Claude desktop, etc. Always include `status: [PENDING]`.
Omit the `domain` line entirely for non-idea types.

For `type: resolution`, include the issue ID in the details
(e.g. "Resolves [ISSUE-001]") so the promoter can match it.

---

## Step 4 — Append to the log

1. Read `{vault_root}/_logs/PENDING_REVIEW.md`
2. Append the formatted entry at the end
3. Write the full updated content back

Use the agent's file edit tools (Filesystem MCP `edit_file`, Claude Code
`Edit`, etc.). If the file doesn't exist, create it with this header
first:

```
---
purpose: agent-write-back
instructions: Agents append entries here. RM reviews each entry and marks its status. The vault-promoter skill handles approved entries automatically.
---

# 📥 Pending Review

Agents append entries below this line.

## How to review

Edit the `status:` field on each entry — or add `[APPROVED]` / `[DISCARDED]` / `[DEFER]` to the entry header — then ask any agent to "promote approved entries".

**Statuses:**
- `[PENDING]` — default; not yet reviewed
- `[APPROVED]` — RM has approved; ready for promotion
- `[PROMOTED]` — agent has moved it to the right file
- `[DISCARDED]` — RM said no; agents ignore
- `[DEFER]` — revisit later; agents ignore

---

<!-- AGENTS: Append your entries below this line. Do not edit anything above it. -->

```

---

## Step 5 — Confirm

Tell RM what was logged in one sentence:

> Logged to pending review: [summary] (`[type]` / `[project]`)

Don't repeat the full entry back. Don't ask if they want to review it.

---

## Rules

- **Append only** — never overwrite or delete existing entries
- **One entry per topic** — multiple distinct items → multiple entries
- **Be specific** — vague entries get discarded at review time
- **Always include `status: [PENDING]`** — the promoter relies on this field
- **Don't invent details** — only log what was actually discussed
