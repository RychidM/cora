---
name: vault-carry
description: >
  Captures a chat session — summary, artifacts produced, and references
  cited — into a dedicated folder under `sessions/{YYYY-MM-DD-slug}/` so
  the working context can be carried into an IDE later. Use this skill
  when RM asks to carry, capture, save, or close out a chat session.
  Trigger phrases include: "carry this session", "carry this chat",
  "save this session", "capture this session", "close this out into a
  session", "carry this discussion", "carry this to my vault". Always
  create the actual session folder and files — do not just summarise
  back to chat.
---

# Vault Carry

Captures the working state of a chat — what was discussed, what came
out of it, what was referenced — into its own folder under `sessions/`
so the context can be carried into your IDE for later work, without
scattering loose files into project repos.

A session has its own folder: `sessions/{YYYY-MM-DD-slug}/` containing
`SESSION.md`, `artifacts/`, and `references/`.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1).

The sessions directory is `{vault_root}/sessions/`. If it doesn't
exist yet, create it along with `sessions/_archive/`.

---

## Step 2 — Identify the session

Walk through the conversation and assemble a proposal. Identify:

- **Slug** — kebab-case, derived from the main topic
  (e.g. `push-proxy-fix-discussion`, `cli-pairing-idea`,
  `q3-direction-thinking`)
- **Scope** — a single vault path indicating where the session is
  conceptually relevant:

| Scope value | When to use |
|-------------|-------------|
| `projects/{project}` | Session about an existing project (or module) |
| `ideas/{domain}` | Session about an idea (technical/product/content/business) |
| `brand/{section}` | Session about identity, aesthetic, or goals |
| `research/topics/{topic}` | Research deep-dive |
| `general` | None of the above |

- **Summary** — 2-3 sentences capturing what the session was about
- **Key points / decisions** — bulleted; only substantive items
- **Artifacts** — code blocks, diagrams, or documents produced in the
  session that are worth saving as files
- **References** — vault links, external URLs, repo file paths cited
  in the conversation; and any external content (article text, paste-ins)
  that should be carried with the session
- **Open threads** — things to follow up on next time

---

## Step 3 — Discuss with RM

Before writing anything, show the proposal:

```
Session proposal:
  Slug:  push-proxy-fix-discussion
  Scope: projects/agentwatch/agentwatch-push-proxy
  Date:  2026-06-02

Summary: {2-3 sentences}

Key points / decisions:
  - ...
  - ...

Artifacts to save (N):
  1. fix-proposal.ts          — TypeScript, ~30 lines
  2. payload-shape.json       — JSON, the required APNs body shape
  3. flow-diagram.mermaid     — sequence diagram of the pairing flow

References to carry (N):
  - Vault link: [[research/topics/apns-push-notifications]]
  - External:   https://developer.apple.com/...
  - Carried:    Article excerpt RM pasted earlier → references/apple-apns-notes.md
  - Repo file:  agentwatch-push-proxy/src/apns.ts:127

Open threads:
  - ...

Anything to add, remove, or change before I file it?
```

Wait for RM's response or implicit go-ahead. Adjust based on feedback.

This collaborative step is **not optional** — it's what makes the
carry capture the right context with the right emphasis.

---

## Step 4 — Create the session folder structure

```
sessions/{YYYY-MM-DD}-{slug}/
├── SESSION.md
├── artifacts/      (only if there are artifacts)
└── references/     (only if there are references to carry as files)
```

Use today's date (UTC) in `YYYY-MM-DD` format.

If a folder with the same date+slug already exists, append a suffix:
`-2`, `-3`, etc. Do not overwrite.

---

## Step 5 — Save artifacts

For each code block or diagram RM confirmed in Step 3:

1. Detect the language hint on the fenced code block
2. Map to a file extension:

| Language hint | Extension |
|---------------|-----------|
| typescript, ts | `.ts` |
| javascript, js | `.js` |
| python, py | `.py` |
| swift | `.swift` |
| kotlin, kt | `.kt` |
| dart | `.dart` |
| go | `.go` |
| rust, rs | `.rs` |
| java | `.java` |
| ruby, rb | `.rb` |
| bash, sh | `.sh` |
| sql | `.sql` |
| json | `.json` |
| yaml, yml | `.yaml` |
| toml | `.toml` |
| html | `.html` |
| css | `.css` |
| mermaid | `.mermaid` |
| markdown, md | `.md` |
| (no hint or unknown) | `.txt` |

3. Number sequentially: `01-`, `02-`, `03-`. The prefix gives stable
   ordering when the folder is listed alphabetically.
4. Write each artifact as `artifacts/{NN}-{descriptive-slug}.{ext}`

Names should be short and descriptive (`01-fix-proposal.ts`, not
`01-the-typescript-code-from-the-conversation.ts`).

---

## Step 6 — Save references

For each reference RM confirmed to carry as a file:

- External text RM pasted (article excerpt, PM feedback, etc.) →
  `references/{descriptive-slug}.md`
- A repo file's content RM dropped into chat for context →
  `references/{filename-from-repo}.{ext}`

For references that are **only links** (URLs, vault wikilinks, repo
paths), do NOT save a file. They go in `SESSION.md` under the
References section as links only.

---

## Step 7 — Write SESSION.md

Use this template:

```markdown
---
type: session
date: YYYY-MM-DD
agent: claude-desktop
scope: {scope value from Step 2}
related:
  - [[wikilink-to-related-vault-item]]
status: active
---

# {Session title — derived from slug, in Title Case}

## Summary

{2-3 sentences. What was this session about, what came out of it.}

## Key points

- {Substantive thing discussed}
- {Decision reached}
- {Question raised}

## Artifacts

- [[artifacts/01-fix-proposal.ts]] — {one-line description}
- [[artifacts/02-payload-shape.json]] — {one-line description}
- [[artifacts/03-flow-diagram.mermaid]] — {one-line description}

*(omit this section if no artifacts)*

## References

- Vault: [[research/topics/apns-push-notifications]]
- Vault: [[projects/agentwatch/agentwatch-push-proxy/OVERVIEW]]
- Carried: [[references/apple-apns-notes]]
- External: https://developer.apple.com/documentation/...
- Repo file: `agentwatch-push-proxy/src/apns.ts:127`

*(omit this section if no references)*

## Open threads

- {Thing to follow up on next time}
- {Unanswered question}

*(omit this section if no open threads)*
```

Notes:

- `related:` in the frontmatter is a list of vault items closely
  connected to this session (the topic page, the idea, the project).
  Cross-links the agent can follow.
- `status: active` is the default. When the session is moved to
  `_archive/`, change to `status: archived`.
- The artifact links use relative paths (`artifacts/...`) since the
  files live in the same folder.

---

## Step 8 — Update `sessions/_INDEX.md`

Add a row to the **Active Sessions** table:

```
| YYYY-MM-DD | [[sessions/{folder-name}/SESSION\|{slug}]] | `{scope}` | N | N |
```

Where the last two columns are the artifact count and reference count.

If `sessions/_INDEX.md` doesn't exist yet, create it from the template
in `AGENTS.md`'s Sessions section.

---

## Step 9 — Report

```
Session carried: {folder-name}

  Summary:   {one line}
  Scope:     {scope value}
  Artifacts: N files written to artifacts/
  References: N files written to references/, N links in SESSION.md

  Index updated: sessions/_INDEX.md

Next:
  - Open the session folder in Obsidian to review
  - From your IDE on {project}, ask "load recent sessions for this project" to pull this in
```

If the session contains items that should also be promoted independently
(a decision worth logging, an article worth ingesting), surface them as
suggestions — do **not** auto-promote.

---

## Rules

- **Always discuss before writing.** Step 3 is mandatory. The carry
  reflects RM's emphasis, not the skill's interpretation alone.
- **Single scope per session.** No multi-scope lists. If a session
  genuinely spans two surfaces, ask RM to split it.
- **One folder per session.** Never put sessions in a flat-file layout.
  Artifacts and references live in subfolders next to `SESSION.md`.
- **Never overwrite an existing session folder.** Append a numeric
  suffix (`-2`, `-3`) if needed.
- **Never auto-promote.** Sessions don't get auto-logged or
  auto-ingested. Surface candidates in the report; let RM decide.
- **Never modify project files.** A session about a project doesn't
  edit that project's OVERVIEW/ISSUES/PROGRESS. If something from the
  session belongs in a project file, RM uses `vault-logger` for it.
- **`status: active` is default.** Sessions become `status: archived`
  only when moved to `_archive/` (manual or via prompt).
- **Artifact numeric prefixes** (`01-`, `02-`) are mandatory for
  stable ordering.
- **References are only saved as files** if there's actual external
  content to carry. Pure links stay as links in `SESSION.md`.
