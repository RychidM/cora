---
name: vault-resume
description: >
  Picks up a past chat session from RM's memory vault inside a fresh chat,
  with no project context assumed. Lists recent sessions across every
  scope, lets RM pick one, then loads it in full so work can continue.
  Use this skill when RM starts a new chat and wants to resume, pick up,
  reopen, or continue a previous session. Trigger phrases include:
  "resume a session", "resume that session", "pick up where I left off",
  "reopen a session", "continue a past session", "load a session here",
  "what was I working on". Read-only — never modifies any vault file.
---

# Vault Resume

Resumes a past session inside the current (often brand-new) chat.

`vault-recall` is the project-bound door: it auto-detects the current
project from the working directory and filters sessions to that scope.
That assumes you're already working inside a project. `vault-resume` is
the **scope-agnostic** door — it makes no assumption about where you are.
It lists the most recent sessions across **all** scopes, lets you pick
one, and loads it in full so you can continue the work in a fresh chat.

Read-only. Never modifies any vault file.

The contract:
- **carry** writes a session out (`vault-carry`)
- **recall** pulls sessions back *for the current project* (`vault-recall`)
- **resume** pulls *any* session back into *any* chat (this skill)

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1). If no `sessions/`
folder exists, tell RM there are no sessions yet and stop.

---

## Step 2 — Parse the invocation

| Invocation | Mode | What it does |
|------------|------|--------------|
| `/vault-resume` (no args) | **browse** | Lists recent sessions across **all** scopes, then loads the one RM picks |
| `/vault-resume <query>` | **match** | Matches a session by slug or keyword; loads it directly if unique, else lists candidates to pick from |

Flags:
- `--limit N` — how many sessions browse mode lists (default 5, max 15)
- `--include-archived` — also consider `sessions/_archive/`

Unlike `vault-recall`, there is **no scope filter and no project
auto-detection**. Resume deliberately spans everything so it works from
a blank chat with zero working-directory context.

---

## Step 3 — Browse mode (no args)

1. Read `sessions/_INDEX.md`
2. Parse the **Active Sessions** table (add `_archive/` rows only if
   `--include-archived` was passed)
3. Sort all rows by date descending — **no scope filtering**
4. Take top N (default 5, max 15)
5. For each session, read `sessions/{folder}/SESSION.md` and extract:
   `scope`, `summary`, top 2 key points, artifact + reference counts,
   top 1 open thread
6. Format the output:

```
Most recent sessions (all scopes):

 1. YYYY-MM-DD — {slug}            `{scope}`
    {summary}
    {artifact-count} artifacts · {reference-count} refs · {open-thread-count} open threads

 2. YYYY-MM-DD — {slug}            `{scope}`
    ...

Which session do you want to resume? (number, or slug)
```

Wait for RM to pick. Then load that session in full via Step 5.

If there are no sessions at all: say so plainly and stop.

---

## Step 4 — Match mode (`/vault-resume <query>`)

1. Read `sessions/_INDEX.md` (plus `_archive/` if `--include-archived`)
2. Match the query against session slugs and `summary` text
   (case-insensitive substring match on both)
3. Resolve:
   - **Exactly one match** → load it in full (Step 5)
   - **Several matches** → list them as in Step 3 and ask RM to pick
   - **No match** → say so, then fall back to listing the most recent
     sessions (Step 3) so RM can pick from what exists

---

## Step 5 — Load a session in full

Once a session is chosen (browse pick or unique match):

1. Find the session folder:
   - Search `sessions/{YYYY-MM-DD}-{slug}/` matching the slug
   - If not found and `--include-archived`, search `sessions/_archive/`
   - If still not found, list candidate slugs and ask
2. Read `sessions/{folder}/SESSION.md` in full
3. List contents of `artifacts/` and `references/`
4. Calculate the total size of all artifact and reference files
5. **If total ≤ 50KB**: load everything into context
6. **If total > 50KB**: load `SESSION.md` and `references/` only;
   list artifacts with sizes and ask which to load:
   > "Artifacts total {X}KB. Which to load? (`all`, comma-separated
   > numbers `01,02,03`, or skip)"
7. Format the output:

```
Resumed session: {folder-name}   `{scope}`

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

## Open threads to pick up
- {from SESSION.md}
```

The **Open threads to pick up** footer is what makes this a resume and
not just a read — surface exactly where the session left off.

---

## Step 6 — Suggestions

After loading, optionally surface follow-up actions in a one-line footer
(do **not** auto-execute):

- If the session has decisions worth logging: *"Want to log any of these
  decisions to pending review? (`vault-logger`)"*
- If the session has carried references worth promoting: *"Want to
  ingest the references into the research library? (`vault-ingest`)"*
- If the resumed work produces new artifacts by the end of this chat:
  *"Want to carry this session forward when you're done? (`vault-carry`)"*

---

## Rules

- **Read-only.** Never modify any vault file from this skill.
- **No scope assumption.** Resume never auto-detects a project or
  filters by scope — that's `vault-recall`'s job. Browse mode spans
  every scope so it works from a blank chat.
- **Browse, then load.** Default behaviour lists recent sessions and
  waits for RM to pick before loading anything in full.
- **Loading is full by default** once a session is chosen — the point of
  resume is to continue the work, not preview it.
- **Confirm large loads.** If total artifact+reference size exceeds
  50KB, list and ask before loading.
- **Honour the archive boundary.** Browse and match exclude
  `sessions/_archive/` unless `--include-archived` is passed.
- **Never auto-promote.** Resumed sessions don't auto-log decisions or
  auto-ingest references; suggestions only.
