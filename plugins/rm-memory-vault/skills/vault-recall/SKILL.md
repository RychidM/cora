---
name: vault-recall
description: >
  Loads recent chat sessions from RM's memory vault back into the current
  agent context. Use this skill when RM asks to load, recall, pull,
  fetch, or open past sessions for the current project or a specific
  scope. Trigger phrases include: "load recent sessions", "recall recent
  sessions", "what did I discuss recently", "pull session context",
  "load sessions for this project", "show me past sessions", "recall
  that session". Read-only — never modifies any vault file.
---

# Vault Recall

Loads sessions from `sessions/` back into the current agent context.
The opposite direction from `vault-carry`: carry IN, recall OUT.

Read-only. Never modifies any vault file. Default behaviour is to
**list session summaries**, not dump full contents — keeps the agent
context lean. Use `full <slug>` to pull a session in completely.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1). If no `sessions/`
folder exists, tell RM there are no sessions yet and stop.

---

## Step 2 — Parse the invocation

Three modes based on arguments:

| Invocation | Mode | What it does |
|------------|------|--------------|
| `/vault-recall` (no args) | **list** | Lists recent sessions for the **current project** (auto-detected) |
| `/vault-recall <scope-prefix>` | **list** | Lists recent sessions matching that scope prefix |
| `/vault-recall full <slug>` | **full** | Loads one session completely (SESSION.md + references; artifacts on request) |

The optional flag `--limit N` changes how many sessions list mode
returns (default 3, max 10).

---

## Step 3 — Resolve the scope prefix (list mode)

If RM gave an explicit scope prefix, use it. Otherwise auto-detect:

1. Get the current working directory (e.g. via `pwd` in Claude Code)
2. Take the basename → the likely project name
3. Search for a matching folder in `projects/`:
   - `projects/{name}/` → scope prefix is `projects/{name}`
   - `projects/{parent}/{name}/` (module) → scope prefix is
     `projects/{parent}/{name}`
4. If found: use that scope prefix
5. If not found: ask RM
   > "Which scope should I recall sessions for? (e.g. `projects/agentwatch`,
   > `ideas/content`, `brand/goals`)"

**Detection caveat:** in Claude desktop, the working directory has no
project context — auto-detection will fail, so the skill should ask
straight away rather than guess.

---

## Step 4 — List mode

1. Read `sessions/_INDEX.md`
2. Parse the **Active Sessions** table
3. Filter rows where `scope` *starts with* the resolved prefix
   (prefix match, not exact — so `projects/agentwatch` matches sessions
   scoped to any agentwatch module)
4. Sort by date descending
5. Take top N (default 3, max 10)
6. For each session:
   - Read `sessions/{folder}/SESSION.md`
   - Extract: `summary`, top 3 key points, artifact count and filenames,
     top 2 open threads
   - List `artifacts/` and `references/` directory contents for counts
7. Format the output:

```
N recent sessions matching `{scope-prefix}`:

## YYYY-MM-DD — {slug}
**Summary:** {summary from SESSION.md}
**Key points:**
  - {top 3}
**Artifacts:** {count} files ({filenames if ≤4, else "...and N more"})
**References:** {count} files + {count} links
**Open threads:**
  - {top 2}
**Path:** `sessions/{folder}/`

## YYYY-MM-DD — {slug}
...

Drill into one with: `/vault-recall full <slug>`
```

If no sessions match the scope: say so plainly. Suggest broadening the
prefix (e.g. from `projects/agentwatch/agentwatch-push-proxy` to
`projects/agentwatch`).

---

## Step 5 — Full mode

When invoked as `/vault-recall full <slug>`:

1. Find the session folder:
   - Search `sessions/{YYYY-MM-DD}-{slug}/` matching the slug
   - If not found, also search `sessions/_archive/`
   - If still not found, list candidate slugs and ask
2. Read `sessions/{folder}/SESSION.md` in full
3. List contents of `artifacts/` and `references/`
4. Calculate total size of all artifact and reference files
5. **If total ≤ 50KB**: load everything into context
6. **If total > 50KB**: load `SESSION.md` and `references/` only;
   list artifacts with sizes and ask which ones to load:
   > "Artifacts total {X}KB. Which to load? (`all`, comma-separated
   > numbers `01,02,03`, or skip)"
7. Format the output:

```
Loaded session: {folder-name}

[Full SESSION.md content embedded here]

## Artifacts loaded
- `artifacts/01-fix-proposal.ts` ({size}, {language})

```{language}
{file content}
```

- `artifacts/02-payload-shape.json` ...

## References loaded
- `references/{filename}.md`

[content]

## Vault links (not auto-loaded — follow if needed)
- [[research/topics/apns-push-notifications]]
- [[projects/agentwatch/agentwatch-push-proxy/OVERVIEW]]

## External links
- https://developer.apple.com/...
```

---

## Step 6 — Suggestions (both modes)

After listing or loading, optionally surface follow-up actions in a
one-line footer:

- If the session has decisions worth logging: *"Want to log any of these
  decisions to pending review? (`vault-logger`)"*
- If the session has carried references worth promoting: *"Want to
  ingest the references into the research library? (`vault-ingest`)"*

Do **not** auto-execute these — they're suggestions.

---

## Rules

- **Read-only.** Never modify any vault file from this skill.
- **Lean by default.** List mode shows summaries, not full contents.
  Full mode is opt-in via the `full` argument.
- **Confirm large loads.** If total artifact+reference size exceeds
  50KB, list and ask before loading.
- **Detection failures ask, don't guess.** When the current project
  can't be inferred, ask which scope to recall — never silently default
  to `general` or all sessions.
- **Prefix match for scope filtering.** `projects/agentwatch` matches
  any session whose scope starts with that path, including modules.
- **Honour the archive boundary.** List mode excludes
  `sessions/_archive/` by default. To include archived sessions, RM
  invokes `/vault-recall <scope> --include-archived`.
- **Never auto-promote.** Loaded sessions don't auto-log decisions or
  auto-ingest references; suggestions only.
