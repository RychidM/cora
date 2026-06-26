---
name: cora-logger
description: >
  Logs ideas, decisions, issues, progress updates, and context from the
  current conversation to the user's Obsidian memory vault. Use this skill
  whenever the user asks to log, save, capture, note, remember, or write
  something to the vault. Trigger phrases include: "log this", "save
  this to my vault", "add this to my memory", "note this down", "remember
  this", "log it", "save it", or any variation. Proposes the write inline,
  waits for the user's approval, then writes directly to the destination —
  there is no pending-review queue.
---

# Vault Logger

Persists an entry to the user's memory vault using the **propose-then-write**
protocol: identify the destination, show the user the full draft inline, wait
for explicit approval, then write directly to the destination file. There
is no `_logs/PENDING_REVIEW.md` staging step and no promoter — **inline
review IS the review.**

This skill is the single owner of the write protocol defined in the
vault's `AGENTS.md` (Write Protocol + Cross-Module Awareness). Keep the
two in sync.

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
   contains `AGENTS.md`.

3. **Default.** `~/obsidian-memory-vault`.

Before using the resolved root, confirm `{vault_root}/AGENTS.md` exists.
If none of the above yields a valid vault, stop and tell the user the vault
could not be located — ask them to set `AGENT_MEMORY_VAULT` (and, for
Claude desktop, add the vault to the Filesystem MCP allowed directories)
rather than writing to a guessed path.

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
to no specific project. Idea entries are domain-scoped, not
project-scoped — see `domain` below.

If genuinely unclear, ask before proposing.

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

## Step 3 — Resolve the destination and cross-module impact

### Primary destination

| Type | Primary destination |
|------|---------------------|
| `issue` | `projects/{project}/ISSUES.md` |
| `resolution` | Update the matching issue in `projects/{project}/ISSUES.md` |
| `progress` | `projects/{project}/PROGRESS.md` |
| `decision` | `projects/{project}/OVERVIEW.md` (Decisions section) |
| `context` | `projects/{project}/OVERVIEW.md` (Notes section) |
| `idea` | `ideas/{domain}.md` |

For non-project entries, brand/research updates go to their respective
files (`brand/PROFILE.md`, `research/topics/{topic}.md`, etc.) using the
same propose-then-write flow.

The destination's existing format governs the entry shape — issue blocks
in `ISSUES.md`, milestone rows in `PROGRESS.md`, idea blocks in
`ideas/{domain}.md`. Follow whatever convention the file already uses;
don't invent new frontmatter for entries inside existing files. For
`type: resolution`, reference the issue ID being resolved (e.g.
"Resolves ISSUE-001").

### Cross-module breadcrumbs

When `project` is a **submodule** (lives under a parent project folder,
e.g. `agentwatch-relay` under `agentwatch`), activity must propagate:

1. **Parent breadcrumb is implicit.** Every submodule write of type
   `issue`, `resolution`, `progress`, or `decision` adds a breadcrumb to
   the parent's `ACTIVITY.md`. You don't ask whether to — it's part of
   every qualifying submodule proposal automatically.

2. **Sibling breadcrumbs are explicit.** Decide which sibling submodules
   this change actually affects and add a breadcrumb to each one's
   `ACTIVITY.md`. Heuristic:
   - Changes a shared contract (protocol, schema, public API)? → every consumer
   - Changes observable behaviour another module depends on? → those modules
   - Purely internal? → none (parent still gets its implicit breadcrumb)

3. **Siblings are sibling submodule names only** (same parent folder),
   not full vault scopes. Genuine cross-project impact is rare — propose
   a separate entry under the other project instead.

4. **`context` and `idea` never trigger breadcrumbs.** `context` is too
   noisy; `idea` is domain-scoped, not project-scoped.

**Breadcrumb format** — single line, most recent at the top of the most
recent date block:

```
# in the parent's ACTIVITY.md (from a submodule):
- 2026-06-06 [agentwatch-relay] [issue] Long-poll timeout dropped 30s→15s, desktop must retune. → [[agentwatch-relay/ISSUES#issue-007]]

# in an affected sibling's ACTIVITY.md:
- 2026-06-06 [from agentwatch-relay] [issue] Long-poll timeout dropped 30s→15s, desktop must retune. → [[../agentwatch-relay/ISSUES#issue-007]]
```

If a target `ACTIVITY.md` doesn't exist yet, create it as part of this
write using the skeleton:

````markdown
---
type: activity
project: {project-name}
last_updated: YYYY-MM-DD
---

# {Project Name} — Activity Feed

> Chronological feed of work touching this project, including cross-module
> breadcrumbs from siblings. Most recent at top.

---

## YYYY-MM-DD

- 2026-06-06 [type] Summary. → [[link]]
````

One date heading per day; entries within a day in any order.

---

## Step 4 — Propose the write inline

Show the user the **full draft** of every file change — the actual text to be
inserted or edited, not a summary. If multiple files are touched (primary
+ parent breadcrumb + sibling breadcrumbs), show them all in one
proposal so a single approval gates the whole consistent set.

Format the proposal as, for each destination:

> **`projects/agentwatch-relay/ISSUES.md`** — append:
> ```
> [full entry text]
> ```
> **`projects/agentwatch/ACTIVITY.md`** — breadcrumb under `## 2026-06-06`:
> ```
> - 2026-06-06 [agentwatch-relay] [issue] … → [[…]]
> ```

Then ask for approval explicitly.

---

## Step 5 — Wait for approval

Do **not** write until the user gives explicit approval — "yes", "approve",
"write it", or specific edits. If the user edits the draft, fold the edits in
and write the revised version. Never write on implicit or assumed
approval, even for small edits.

---

## Step 6 — Write all destinations

Once approved, write every file in the proposal in one batched pass using
the agent's file edit tools (Claude Code `Edit`/`Write`, Filesystem MCP
`edit_file`, etc.):

1. Insert the entry into the primary destination in its native format.
2. Add the parent breadcrumb (if a qualifying submodule write).
3. Add each sibling breadcrumb listed.
4. Bump `last_updated:` on any `ACTIVITY.md` touched.

---

## Step 7 — Confirm

Tell the user exactly what was written, in one line per file:

> Wrote to `projects/agentwatch-relay/ISSUES.md` (`issue` / agentwatch-relay)
> Breadcrumb added to `projects/agentwatch/ACTIVITY.md`

Don't repeat the full entry back.

---

## Rules

- **Never write without explicit approval** — even small edits.
- **Show the full draft, not a summary** — the user reviews the actual text.
- **Batch related writes** — primary + breadcrumbs go up as one proposal,
  get one approval, write together.
- **One entry per topic** — multiple distinct items → multiple entries.
- **Be specific** — reference file paths, line numbers, commit SHAs, URLs.
- **Don't invent details** — only write what was actually discussed.
- **Resolutions reference the issue ID** they resolve.
