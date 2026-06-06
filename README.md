# RM Memory Vault — Claude Plugin

A Claude plugin that turns RM's Obsidian-based memory vault into a
first-class agent capability. Log ideas, promote reviewed entries, sync
agent files to project repos, search the vault, and manage projects —
all from chat with any Claude agent (Claude Code, Claude desktop).

---

## What this plugin does

The vault is a structured Obsidian repository that holds RM's projects,
ideas, identity, and agent write-back log. Without this plugin, every
operation on the vault is manual: copy entries, move them between files,
update indexes, regenerate per-repo agent context, archive old entries.

With this plugin installed, any Claude agent can do all of those things
directly. Every action that touches the vault has a skill behind it, and
each skill has a slash command for explicit invocation.

---

## Installation

### From the Claude marketplace (when published)

```
/plugin install rm-memory-vault
```

### From this repository (local dev)

```bash
git clone https://github.com/RychidM/rm-memory-vault-plugin.git
cd rm-memory-vault-plugin

# Claude Code
ln -s "$(pwd)" ~/.claude/plugins/rm-memory-vault

# Claude desktop
# (Drop the folder into the Claude desktop plugins directory or use
# Settings → Plugins → Install from folder)
```

---

## Configuration

The plugin needs to know where your vault lives. Set:

```bash
export AGENT_MEMORY_VAULT="$HOME/obsidian-memory-vault"
```

On macOS with the vault in iCloud:

```bash
export AGENT_MEMORY_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/<your-vault>"
```

**The env var must be visible to the agent's process, not just your
terminal.** A skill reads it by running `echo "$AGENT_MEMORY_VAULT"`, so the
variable has to be exported in the environment that launched Claude — put the
`export` in your shell profile (`~/.zshrc`) and start Claude Code from that
shell. Setting it in an unrelated terminal after Claude is already running has
no effect.

**Claude desktop has no shell**, so the env var can't be read there. Add the
vault to the Filesystem MCP's allowed directories instead — the plugin then
locates it via `list_allowed_directories`.

If neither resolves, the plugin falls back to `~/obsidian-memory-vault`, and
if that doesn't exist it stops and asks rather than writing to a guessed path.

---

## Skills and commands

| Skill | Command | What it does |
|-------|---------|--------------|
| `vault-logger` | `/vault-log` | Append a structured entry to the pending review log |
| `vault-promoter` | `/vault-promote` | Move `[APPROVED]` entries to their destination files |
| `vault-status` | `/vault-status` | Show projects, open issues, pending log counts |
| `vault-project-init` | `/vault-init` | Create a new project or module from the template |
| `vault-project-sync` | `/vault-sync` | Write fresh `CLAUDE.md`/`GEMINI.md`/etc. to a repo |
| `vault-find` | `/vault-find` | Search across projects, ideas, brand, log |
| `vault-log-archive` | `/vault-archive` | Move promoted/discarded entries into monthly archives |
| `vault-review` | `/vault-review` | Approve/discard/defer pending entries from chat |
| `vault-read` | `/vault-read` | Return the full content of a file or entry |
| `vault-edit` | `/vault-edit` | Make a direct in-place edit to existing content |
| `vault-idea-status` | `/vault-idea` | Advance an idea's lifecycle status |
| `vault-project-status` | `/vault-project-status` | Set project status or archive a project |
| `vault-move` | `/vault-move` | Rename a project or relocate a module, fixing all references |
| `vault-ingest` | `/vault-ingest` | Process a research source into topic synthesis pages |
| `vault-lint` | `/vault-lint` | Health-check the vault (orphans, stale topics, drift) |
| `vault-carry` | `/vault-carry` | Capture a chat session (summary + artifacts + references) into `sessions/` |

You don't have to use the slash commands — skills auto-trigger on
matching phrases ("log this", "promote approved", "search vault for X").

For a per-skill reference card (inputs, what each reads/writes, rules),
see [`docs/skills/`](docs/skills/README.md).

### Operation coverage

Every vault surface now has create / read / update / lifecycle coverage:

| Surface | Create | Read | Update | Lifecycle / remove |
|---------|--------|------|--------|--------------------|
| Pending log | `vault-logger` | `vault-status`, `vault-find`, `vault-read` | `vault-review`, `vault-promoter` | `vault-log-archive` |
| Projects | `vault-project-init` | `vault-status`, `vault-read` | `vault-edit`, `vault-promoter`, `vault-move` (rename/relocate) | `vault-project-status` (incl. archive) |
| Ideas | `vault-logger` → `vault-promoter` | `vault-find`, `vault-read` | `vault-edit` | `vault-idea-status` |
| Issues | `vault-logger` → `vault-promoter` | `vault-find`, `vault-read` | `vault-edit`, `vault-promoter` (resolve) | — |
| Brand | — | `vault-find`, `vault-read` | `vault-edit` | — |
| Repo agent files | `vault-project-sync` | — | `vault-project-sync` | — |
| Research | `vault-ingest` | `vault-find`, `vault-read`, `vault-lint` | `vault-ingest` (re-ingest) | — |
| Sessions | `vault-carry` | `vault-find`, `vault-read`, `vault-lint` | (manual edit) | (manual move to `_archive/`) |

---

## Typical workflow

### The core loop — log → review → promote → archive

1. **During work**, in Claude Code or Claude desktop, say:
   > "Log this decision to my vault."

   The `vault-logger` skill writes a `[PENDING]` entry to
   `_logs/PENDING_REVIEW.md`.

2. **Later**, review each `[PENDING]` entry. Either open the vault in
   Obsidian and change the status field, or do it from chat:
   > "Approve the agentwatch entries, discard the rest."

   The `vault-review` skill applies your decision in place.

3. **Back in Claude**, say:
   > "Promote approved entries."

   The `vault-promoter` skill moves each `[APPROVED]` entry to its
   destination file (issues to `ISSUES.md`, decisions to `OVERVIEW.md`,
   ideas to `ideas/{domain}.md`, etc.) and marks them `[PROMOTED]`.

4. **Periodically**, say:
   > "Archive the log."

   The `vault-log-archive` skill moves promoted/discarded entries into
   `_logs/archive/YYYY-MM.md`, keeping the review log focused.

### Looking things up

- > "What did I note about pairing flow?" → `vault-find` returns ranked
  snippets across projects, ideas, brand, and the log.
- > "Show me the full agentwatch overview." → `vault-read` returns the
  complete file or entry, not just snippets.
- > "Where do things stand?" → `vault-status` summarises projects, open
  issues, and pending-log counts.

### Editing what already exists

When something in the vault is wrong rather than new, skip the log:

> "Fix the typo in the agentwatch style guide."

The `vault-edit` skill makes a surgical in-place edit, confirms a
before → after first, and records the change as a `[PROMOTED]` context
entry so it stays traceable. (New knowledge still goes through
`vault-logger` so it gets reviewed.)

### Moving things through their lifecycle

- > "The offline-sync idea is shipped." → `vault-idea-status` advances the
  idea and moves it to the shipped/archived section.
- > "Mark agentwatch active." / "Archive the foo project." →
  `vault-project-status` updates the status across `PROGRESS.md`,
  `_INDEX.md`, and `AGENTS.md`; archiving relocates the folder to
  `projects/_archive/`.

### Setting up and reshaping projects

- > "Create a new project called bar." → `vault-project-init` scaffolds
  the folder from the template and registers it.
- > "Sync agent files for this repo." → `vault-project-sync` writes fresh
  `CLAUDE.md`/`GEMINI.md`/etc. into the repo.
- > "Rename agentwatch to agentscope." / "Move foo under bar." →
  `vault-move` relocates the folder and repoints every reference and
  `[[wikilink]]`. Re-run the sync afterward — agent files go stale on a
  move.

### Building up research

Beyond logging your own thoughts, the vault accumulates **external
research** — articles, framework docs, technical analyses, your reading
notes — in a separate `research/` layer with immutable sources and
LLM-maintained topic synthesis pages.

- > "Ingest the article I just clipped." → `vault-ingest` reads the source,
  proposes which topic page(s) to update, and after your go-ahead writes
  the synthesis into `research/topics/{slug}.md`. Cross-links to relevant
  projects.
- > "Lint the vault." → `vault-lint` reports orphan pages, stale topics,
  unresolved source conflicts, missing topic pages, review backlog, and
  `AGENTS.md`/projects-folder drift. Read-only; fixes are your call.

Source files are immutable from the moment they land. Topic pages
evolve as new sources are ingested — the Summary is rewritten in full
on each update, never appended to.

### Capturing chat sessions

Ideas, debugging threads, and design discussions often happen in chat
before they're ready to become project files or research entries.
Rather than scatter loose files into your project repo or promote
everything piece-by-piece, the carry skill captures the whole thread
as one piece.

- > "Carry this session." → `vault-carry` reads the conversation,
  proposes a slug + scope (with you in the loop), then writes
  `sessions/{YYYY-MM-DD}-{slug}/SESSION.md` plus an `artifacts/` folder
  (code, diagrams, documents from the chat) and a `references/` folder
  (external materials carried with the session). One folder per session.

Scope is flexible — a session can be about a project, an idea
(technical / product / content / business), a brand topic, a research
topic, or `general`. Not every session ties to a project.

- > "Load recent sessions for this project." — in an IDE, ask the agent
  to pull sessions whose scope matches the current project. Sessions are
  **not** auto-included in `CLAUDE.md`; loading is opt-in to keep agent
  files predictable.

A session can be promoted later — a decision logged via `vault-logger`,
a carried article ingested via `vault-ingest`, an artifact moved into
the project. The session itself stays as the historical trace.

Sessions older than 60 days get flagged by `vault-lint` for manual
archival to `sessions/_archive/`.

---

## Vault structure (expected)

```
obsidian-memory-vault/
├── AGENTS.md                 ← Global agent entry point
├── _logs/
│   ├── PENDING_REVIEW.md     ← Agent write-back log
│   └── archive/              ← Monthly archives
├── projects/
│   ├── _INDEX.md
│   ├── _TEMPLATE/            ← Template files used by /vault-init
│   ├── _archive/            ← Retired projects (moved by /vault-project-status)
│   └── {project}/
│       ├── OVERVIEW.md
│       ├── STYLE.md
│       ├── ISSUES.md
│       ├── PROGRESS.md
│       └── {module}/         ← Nested modules
├── brand/                    ← Profile, aesthetic, goals
├── ideas/
│   ├── technical.md
│   ├── product.md
│   ├── content.md
│   └── business.md
└── research/
    ├── _INDEX.md             ← Topic catalog
    ├── _logs/
    │   └── INGEST_LOG.md     ← Chronological ingest record
    ├── sources/              ← Immutable raw material
    │   ├── articles/
    │   ├── docs/
    │   ├── analyses/
    │   └── notes/
    └── topics/               ← LLM-maintained synthesis pages

sessions/
├── _INDEX.md                 ← Active + archived catalog
├── _archive/                 ← Sessions >60 days old
└── {YYYY-MM-DD}-{slug}/      ← One folder per session
    ├── SESSION.md            ← Summary, key points, links
    ├── artifacts/            ← Code, diagrams, documents from the chat
    └── references/           ← External materials carried with the session
```

If you don't have this structure yet, the
[rm-memory-vault](https://github.com/RychidM/rm-memory-vault) starter sets it
up.

---

## Status semantics

Entries in `_logs/PENDING_REVIEW.md` carry a status field:

| Status | Meaning |
|--------|---------|
| `[PENDING]` | Default. Not yet reviewed. |
| `[APPROVED]` | RM has approved. Ready for promotion. |
| `[PROMOTED]` | Agent has moved it to its destination. |
| `[DISCARDED]` | RM said no. Agents ignore. |
| `[DEFER]` | Revisit later. Agents ignore. |

`vault-promoter` only touches `[APPROVED]` entries. It never deletes —
archival is a separate step (`vault-log-archive`).

---

## Design notes

- **Read-only skills** (`vault-status`, `vault-find`, `vault-read`) never
  write to the vault.
- **Write skills** are append-only or transform-in-place — none ever
  delete content. Archiving (`vault-log-archive`, `vault-project-status`)
  relocates content, never destroys it.
- **Review-gated by default.** The vault's normal flow is
  `logger → review → promote`, so RM's approval stays in the loop.
  `vault-review` only applies decisions RM states (it never approves on
  RM's behalf) and `vault-edit` bypasses the log only with a
  before → after confirmation, then records the change as a `[PROMOTED]`
  context entry so every direct edit is traceable.
- **Marker flips** (`[APPROVED]` → `[PROMOTED]`) use a schema-preserving
  two-line anchor pattern to prevent accidental field deletion during
  edits.
- **Module support**: projects can be nested one level deep
  (`projects/{parent}/{module}/`). The sync skill automatically includes
  parent OVERVIEW context for modules.

---

## License

MIT
