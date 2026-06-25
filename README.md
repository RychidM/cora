# RM Memory Vault — Claude, Copilot & Gemini CLI Plugin

A Claude, Copilot and Gemini CLI plugin that turns RM's Obsidian-based memory vault into a
first-class agent capability. Capture ideas and decisions, sync agent
files to project repos, search the vault, and manage projects — all from
chat with any Claude agent (Claude Code, Claude desktop), Copilot, or Gemini CLI. Writes are
proposed inline and land in their destination on your approval; there is
no pending-review queue.

---

## What this plugin does

The vault is a structured Obsidian repository that holds RM's projects,
ideas, identity, research, and per-project activity feeds. Without this
plugin, every operation on the vault is manual: write entries to the
right file, propagate cross-module breadcrumbs, update indexes,
regenerate per-repo agent context, archive old content.

With this plugin installed, any supported agent (Claude, Copilot, Gemini) can do all of those things
directly. Every action that touches the vault has a skill behind it, and
each skill has a slash command for explicit invocation.

---

## Features at a glance

| | |
|---|---|
| **Automatic cross-module breadcrumbs** | Logging work in a module automatically drops a breadcrumb in its parent's activity feed (and named siblings'), so no agent works blind to related work. |
| **Project lifecycle skills** | Scaffold, rename, relocate, promote/demote, and archive projects and modules — every reference (`_INDEX.md`, `AGENTS.md`, wikilinks) is kept consistent for you. |
| **Research ingestion** | Turns a clipped article, doc, or analysis into an LLM-maintained topic page, cross-linked to the projects it's relevant to. |
| **Session capture & resume** | Carries a chat's working context into the vault, then recalls or resumes it later — in the same project or a brand-new chat. |
| **Vault health checks** | `vault-lint` surfaces orphan pages, stale topics, broken wikilinks, and structural drift in a single report. |
| **Per-repo agent context sync** | Generates `CLAUDE.md`/`GEMINI.md`/`.github/copilot-instructions.md`/Codex `AGENTS.md` for any project repo from the vault's own content. |
| **Works across agents** | Claude Code, Claude Desktop, GitHub Copilot CLI, Gemini CLI, and OpenAI Codex all read the same `skills/`. |
| **Propose-then-write capture** | Drafts the exact edit for any idea, decision, issue, progress update, or context note, waits for your approval, then writes it. No pending-review queue. |

---

## Installation

Each tool loads plugins a different way — the same `skills/` power all of them, but the
manifest (and installation mechanism) each one reads differs. Pick your tool below.

### Claude Code (CLI)

Reads `.claude-plugin/marketplace.json` + `.claude-plugin/plugin.json`.

```
/plugin marketplace add RychidM/rm-memory-vault-plugin
/plugin install rm-memory-vault@rm-plugins
```

### Claude Desktop

Claude Desktop doesn't support the `/plugin` slash commands above (those
are Claude Code CLI-only) — it has its own GUI flow that reads the same
`.claude-plugin/marketplace.json` + `.claude-plugin/plugin.json`:

1. In a chat, click the **+** icon next to the message box.
2. Select **Plugins → Add Plugin**. A dialog opens.
3. In that dialog, select **Personal**, then click the **+** icon again.
4. Choose **Add from a repository** and enter `RychidM/rm-memory-vault-plugin`
   (or the full GitHub URL).
5. Select `rm-memory-vault` from the marketplace and install.

Manage or reconfigure installed plugins later from the **Customize** menu.

Claude Desktop has no shell to read `$AGENT_MEMORY_VAULT` from — see
[Configuration](#configuration) below for the Filesystem connector it
uses instead to locate your vault.

### GitHub Copilot CLI

Reads `.github/plugin/marketplace.json` + the root `plugin.json` (skills are
discovered from `skills/`).

```
/plugin marketplace add RychidM/rm-memory-vault-plugin
/plugin install rm-memory-vault@rm-plugins
```

### Gemini CLI

Reads `gemini-extension.json` + the TOML slash commands in `commands/`.

```bash
gemini extensions install https://github.com/RychidM/rm-memory-vault-plugin
# or, from a local clone:
gemini extensions install .
```

### OpenAI Codex

Reads `.agents/plugins/marketplace.json` + the plugin manifest at
`plugins/rm-memory-vault/.codex-plugin/plugin.json`.

```bash
codex plugin marketplace add RychidM/rm-memory-vault-plugin
codex plugin add rm-memory-vault@rm-plugins
```

For context, run `/vault-sync` (or the `vault-project-sync` skill) in a repo
to generate its local `AGENTS.md`. `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`
are git-ignored — they hold personal vault memory and are generated per-repo,
never committed.

### From this repository (local dev)

```bash
git clone https://github.com/RychidM/rm-memory-vault-plugin.git
cd rm-memory-vault-plugin

# Claude
ln -s "$(pwd)" ~/.claude/plugins/rm-memory-vault
# Copilot / Codex / Gemini: use the marketplace/link commands above with a
# local path instead of the GitHub repo (e.g. `gemini extensions link .`,
# `codex plugin marketplace add .`).
```

> **Editing skills?** The repo-root `skills/` is canonical. Codex installs by
> copying its plugin subdir, so it needs an in-tree copy at
> `plugins/rm-memory-vault/skills/`. After changing `skills/`, run
> `./scripts/sync-codex-skills.sh` before committing to keep the copy in sync.

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
variable has to be exported in the environment that launched Claude or Gemini — put the
`export` in your shell profile (`~/.zshrc`) and start Claude Code or Gemini CLI from that
shell. Setting it in an unrelated terminal after Claude is already running has
no effect.

**Claude Desktop has no shell**, so the env var can't be read there. Instead,
install the [Filesystem connector](https://claude.ai/directory/connectors/ant.dir.ant.anthropic.filesystem)
and add your vault folder to its allowed directories — the plugin then
locates it via `list_allowed_directories`.

If neither resolves, the plugin falls back to `~/obsidian-memory-vault`, and
if that doesn't exist it stops and asks rather than writing to a guessed path.

---

## Skills and commands

| Skill | Command | What it does |
|-------|---------|--------------|
| `vault-logger` | `/vault-log` | Propose an entry inline, then write it to its destination on approval (+ cross-module breadcrumbs) |
| `vault-status` | `/vault-status` | Show projects, open issues, recent activity |
| `vault-project-init` | `/vault-init` | Create a new project or module from the template |
| `vault-project-sync` | `/vault-sync` | Write fresh `CLAUDE.md`/`GEMINI.md`/etc. to a repo |
| `vault-find` | `/vault-find` | Search across projects, ideas, brand, research |
| `vault-read` | `/vault-read` | Return the full content of a file or entry |
| `vault-edit` | `/vault-edit` | Make a direct in-place edit to existing content |
| `vault-idea-status` | `/vault-idea` | Advance an idea's lifecycle status |
| `vault-project-status` | `/vault-project-status` | Set project status or archive a project |
| `vault-move` | `/vault-move` | Rename a project or relocate a module, fixing all references |
| `vault-ingest` | `/vault-ingest` | Process a research source into topic synthesis pages |
| `vault-lint` | `/vault-lint` | Health-check the vault (orphans, stale topics, drift) |
| `vault-carry` | `/vault-carry` | Capture a chat session (summary + artifacts + references) into `sessions/` |
| `vault-recall` | `/vault-recall` | Load recent sessions back into the current agent context |
| `vault-resume` | `/vault-resume` | Pick up any past session in a fresh chat (no project context assumed) |

You don't have to use the slash commands — skills auto-trigger on
matching phrases ("log this", "what's been happening", "search vault for X").

For a per-skill reference card (inputs, what each reads/writes, rules),
see [`docs/skills/`](docs/skills/README.md).

### Operation coverage

Every vault surface now has create / read / update / lifecycle coverage:

| Surface | Create | Read | Update | Lifecycle / remove |
|---------|--------|------|--------|--------------------|
| Projects | `vault-project-init` | `vault-status`, `vault-read` | `vault-logger`, `vault-edit`, `vault-move` (rename/relocate) | `vault-project-status` (incl. archive) |
| Activity feeds | `vault-project-init` (top-level projects only; `vault-logger` as fallback if missing) | `vault-status`, `vault-read`, `vault-find` | `vault-logger` (breadcrumbs) | (manual trim) |
| Ideas | `vault-logger` | `vault-find`, `vault-read` | `vault-edit` | `vault-idea-status` |
| Issues | `vault-logger` | `vault-find`, `vault-read` | `vault-logger` (resolve), `vault-edit` | — |
| Brand | — | `vault-find`, `vault-read` | `vault-edit` | — |
| Repo agent files | `vault-project-sync` | — | `vault-project-sync` | — |
| Research | `vault-ingest` | `vault-find`, `vault-read`, `vault-lint` | `vault-ingest` (re-ingest) | — |
| Sessions | `vault-carry` | `vault-recall`, `vault-resume`, `vault-find`, `vault-read`, `vault-lint` | (manual edit) | (manual move to `_archive/`) |

---

## Typical workflow

### Capturing knowledge — propose, approve, write

There is no pending-review queue. An entry goes straight to its
destination once you approve it — **inline review is the review.**

1. **During work**, in Claude Code, Claude desktop, or Gemini CLI, say:
   > "Log this decision to my vault."

   The `vault-logger` skill resolves the destination from the entry type
   (issues → `ISSUES.md`, decisions → `OVERVIEW.md`, ideas →
   `ideas/{domain}.md`, etc.), works out any cross-module breadcrumbs,
   and shows you the **full draft of every file it will touch**.

2. **You approve or edit in chat:**
   > "Yes, write it." / "Change the summary to … then write."

   The skill writes all destinations in one batched pass and confirms
   exactly what landed where. Nothing is written without your approval.

For a submodule, the write automatically adds a breadcrumb to the
parent's `ACTIVITY.md`; siblings get a breadcrumb only when the change
explicitly `affects:` them. See **Activity & cross-module awareness**
below.

### Looking things up

- > "What did I note about pairing flow?" → `vault-find` returns ranked
  snippets across projects, ideas, brand, and research.
- > "Show me the full agentwatch overview." → `vault-read` returns the
  complete file or entry, not just snippets.
- > "Where do things stand?" / "What's been happening?" → `vault-status`
  summarises projects, open issues, and recent activity.

### Editing what already exists

When something in the vault is wrong rather than new:

> "Fix the typo in the agentwatch style guide."

The `vault-edit` skill makes a surgical in-place edit and confirms a
before → after first. Traceability comes from version history. (New
knowledge still goes through `vault-logger`, which resolves the
destination and breadcrumbs for you.)

### Activity & cross-module awareness

Every top-level project has an `ACTIVITY.md` — a rollup feed of
breadcrumbs from its modules' work, newest first. It's scaffolded at
creation, but stays empty until the project actually has a module;
standalone projects with no modules never populate it.

- **Every module-scoped write of type `issue`, `resolution`, `progress`,
  or `decision`** (via `vault-logger`) drops a breadcrumb in its
  **parent's** `ACTIVITY.md`. (`context` and `idea` writes don't — too
  noisy / domain-scoped. Writes to a standalone project never touch
  `ACTIVITY.md` at all — they only land in that project's own
  `ISSUES.md`/`PROGRESS.md`/`OVERVIEW.md`.)
- **Sibling breadcrumbs are explicit.** If the change `affects:` sibling
  modules, each named sibling gets its own breadcrumb in the same
  parent's `ACTIVITY.md` too — all batched into the same approval.

At the start of a session in a module, an agent reads the parent's
`ACTIVITY.md` and surfaces the last few entries, so no module works
blind to what its siblings have been doing.

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

A session can be drawn down later — a decision written via `vault-logger`,
a carried article ingested via `vault-ingest`, an artifact moved into
the project. The session itself stays as the historical trace.

Sessions older than 60 days get flagged by `vault-lint` for manual
archival to `sessions/_archive/`.

#### Loading sessions back into your IDE

When you're working on a project and want past session context:

- > "Load recent sessions for this project." → `vault-recall` lists the
  3 most recent active sessions whose scope matches the current project
  (auto-detected from the working directory). Summary + key points +
  artifact filenames only — keeps agent context lean.
- > "Recall sessions about the article series." →
  `/vault-recall ideas/content` filters by an explicit scope prefix
  instead of the current project.
- > "Load that push-proxy fix session in full." →
  `/vault-recall full push-proxy-fix-discussion` pulls one session's
  `SESSION.md` and references; for artifacts >50KB total the skill
  lists them with sizes and lets you pick.

Recall is read-only. It never auto-promotes anything — if a loaded
session has a decision worth logging or a reference worth ingesting,
the skill mentions it in a one-line footer; you decide.

#### Resuming a session in a fresh chat

`vault-recall` assumes you're inside a project — it auto-detects the
current project and filters sessions to that scope. When you open a
**brand-new chat** with no project context and just want to pick up
where you left off, use `vault-resume` instead. It makes no scope
assumption:

- > "Resume a session." / "What was I working on?" → `vault-resume`
  lists the most recent sessions across **all** scopes, you pick one,
  and it loads that session in full so you can continue the work.
- > "Resume the push-proxy fix session." →
  `/vault-resume push-proxy-fix` matches by slug or keyword and loads it
  directly if the match is unique.

Like recall, resume is read-only and never auto-promotes. The
difference is the door: recall is project-bound, resume is
scope-agnostic.

---

## Vault structure (expected)

```
{vault_root}/
├── AGENTS.md                 ← Global agent entry point + Write Protocol
├── .project-paths            ← One repo path per line (registered by /vault-init)
├── projects/
│   ├── _INDEX.md
│   ├── _TEMPLATE/            ← Template files used by /vault-init (incl. ACTIVITY.md)
│   ├── _archive/             ← Retired projects (moved by /vault-project-status)
│   └── {project}/            ← Top-level project
│       ├── OVERVIEW.md       ← parent:/submodules: frontmatter declares relationships
│       ├── STYLE.md
│       ├── ISSUES.md
│       ├── PROGRESS.md
│       ├── ACTIVITY.md       ← Rollup of submodule breadcrumbs (every top-level
│       │                        project has one; modules don't)
│       └── {module}/         ← Nested module — OVERVIEW/STYLE/ISSUES/PROGRESS
│                                only, no ACTIVITY.md of its own
├── brand/                    ← Profile, aesthetic, goals
├── ideas/
│   ├── _INDEX.md
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
[agent-memory-vault-template](https://github.com/RychidM/agent-memory-vault-template)
starter sets it up. Its `scripts/` (`init-project.sh`, `sync-memory.sh`,
`memory-wrappers.sh`) cover the same operations from a plain shell, no
agent required — this plugin's skills are the agent-driven equivalent,
and both write the same files and frontmatter, so you can mix and match.

---

## The write contract

Every write to the vault — new or edit — passes one gate: **RM sees it
before it lands.** `vault-logger` proposes the full draft of every file
it will touch, waits for explicit approval, then writes all destinations
in one batched pass. There is no pending-review log, no `status:` field,
and no separate promote step — inline review *is* the review.

Entry types resolve to destinations like so:

| Type | Destination |
|------|-------------|
| `issue` | `projects/{project}/ISSUES.md` |
| `resolution` | the matching issue in `ISSUES.md` |
| `progress` | `projects/{project}/PROGRESS.md` |
| `decision` | `projects/{project}/OVERVIEW.md` (Decisions) |
| `context` | `projects/{project}/OVERVIEW.md` (Notes) |
| `idea` | `ideas/{domain}.md` |

`issue` / `resolution` / `progress` / `decision` writes made under a
**module** also drop an activity breadcrumb in its parent's
`ACTIVITY.md` (always), and in named siblings' via `affects:`.
Standalone (non-module) project writes never touch `ACTIVITY.md`. The
full contract lives in the vault's `AGENTS.md`.

---

## Design notes

- **Read-only skills** (`vault-status`, `vault-find`, `vault-read`) never
  write to the vault.
- **Write skills** are append-only or transform-in-place — none ever
  delete content. Archiving (`vault-project-status`) relocates content,
  never destroys it.
- **Approval-gated by default.** No write lands without RM seeing the
  exact text first. `vault-logger` shows the full draft and waits;
  `vault-edit` confirms a before → after for non-trivial changes.
- **Cross-module awareness.** Submodule writes propagate to the parent
  implicitly and to named siblings explicitly, batched into one approval,
  so no module works blind to another.
- **Module support**: projects can be nested one level deep
  (`projects/{parent}/{module}/`). The sync skill automatically includes
  parent OVERVIEW context for modules.

---

## License

MIT
