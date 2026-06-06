# Changelog

## [2.0.0] — 2026-06-06

**Breaking.** Aligns the plugin with AGENTS.md v2.0: the pending-review
queue is gone, replaced by propose-then-write, and projects gain
cross-module activity feeds. Any agent or workflow built against the
v1.x write contract (appending to `_logs/PENDING_REVIEW.md`, the
`status:` field, the promote step) will no longer work.

### Removed
- `vault-promoter` / `/vault-promote` — no promote step; writes land
  directly on approval.
- `vault-review` / `/vault-review` — inline review replaces queue review.
- `vault-log-archive` / `/vault-archive` — no review log to archive.

### Changed
- `vault-logger` (`/vault-log`) repurposed to **propose-then-write**: it
  resolves the destination from the entry type, shows the full draft of
  every file it will touch, waits for explicit approval, then writes all
  destinations in one batched pass. No `_logs/PENDING_REVIEW.md`, no
  `status:` field.
- `vault-logger` now owns **cross-module awareness**: project-scoped
  `issue`/`resolution`/`progress`/`decision` writes add an entry to the
  project's `ACTIVITY.md`; submodule writes add an implicit breadcrumb to
  the parent and explicit breadcrumbs to siblings named in `affects:`.
- `vault-project-init` scaffolds an empty `ACTIVITY.md` for every new
  project/module (from the skeleton if the template lacks one).
- `vault-lint` Check 6 swapped from "pending review backlog" to
  **ACTIVITY.md health** (missing feeds, stale feeds, orphaned
  breadcrumbs).
- `vault-status` reports **recent activity** across projects instead of
  pending-review counts.
- `vault-edit` no longer self-logs a `[PROMOTED]` context record;
  traceability comes from version history.
- `vault-find` / `vault-read` search/resolve `ACTIVITY.md` and research
  files; dropped the pending-log surface.

### Migration
- Write the final `[APPROVED]` pending entry, then archive
  `_logs/PENDING_REVIEW.md` (done in the vault: moved to
  `_logs/_archive/`).
- Backfill `ACTIVITY.md` for existing projects/modules so session-start
  reads have a target (vault-side; not shipped in the plugin).
- Re-run `/vault-sync` on wired repos so their `CLAUDE.md` reflects the
  v2.0 write protocol.

### Documentation
- README rewritten around propose-then-write and activity/cross-module
  awareness; removed the log → review → promote → archive loop, status
  semantics, and the pending-log surface from the operation matrix.
- `docs/skills/` index and cards updated; removed the three obsolete
  cards.

## [1.5.0] — 2026-06-06

Scope-agnostic session resume — pick up any session in a fresh chat.

`vault-recall` is project-bound: it auto-detects the current project from
the working directory and filters sessions to that scope, which assumes
you're already inside a project. This release adds `vault-resume` for the
other case — opening a brand-new chat with no project context and wanting
to continue a past session.

### Skills
- `vault-resume` — read-only. Browse mode lists the most recent sessions
  across **all** scopes (no project auto-detection, no scope filter),
  RM picks one, and it loads in full. Match mode (`/vault-resume <query>`)
  resolves a session by slug or keyword. Surfaces the session's open
  threads as a "pick up" footer so resuming continues the work rather
  than just previewing it.

### Commands
- `/vault-resume` — browse: list recent sessions (all scopes), load on pick
- `/vault-resume <query>` — match by slug or keyword, load if unique
- Flags: `--limit N` (default 5, max 15), `--include-archived`

### Documentation
- README: skill table extended; Sessions row in the operation coverage
  matrix now lists `vault-resume` under Read; new "Resuming a session in
  a fresh chat" subsection.
- `docs/skills/vault-resume.md` reference card; index gains the skill
  under Sessions.
- `docs/skills/vault-recall.md` and `docs/skills/vault-carry.md` gain
  `vault-resume` in their Related sections.

### Design notes
- **Resume is the scope-agnostic door; recall is the project-bound door.**
  Resume never auto-detects a project or filters by scope — that's the
  one behavioural line that separates the two skills.
- **Browse, then load.** Default behaviour lists and waits for a pick;
  loading is full by default once chosen, since the intent is to continue
  the work.
- **Large artifact loads ask first**, mirroring `vault-recall` (>50KB
  total prompts for selection).

## [1.4.0] — 2026-06-02

Session recall — the counterpart to `vault-carry`.

v1.3.0 captured chat sessions into `sessions/`. This release closes the
loop by adding `vault-recall`, which loads sessions back into agent
context when working in an IDE or chat. The carry/recall pair is the
complete session lifecycle: carry IN, recall OUT.

### Skills
- `vault-recall` — read-only. Lists recent sessions matching a scope
  prefix, or loads one session fully (`SESSION.md` + references; large
  artifacts opt-in). Auto-detects the current project from the working
  directory in Claude Code; asks for scope when detection fails
  (e.g. Claude desktop).

### Commands
- `/vault-recall` — list mode (current project, auto-detected)
- `/vault-recall <scope-prefix>` — list mode with explicit scope
- `/vault-recall full <slug>` — load one session completely
- Flags: `--limit N`, `--include-archived`

### Documentation
- README: skill table extended; Sessions row in the operation coverage
  matrix now lists `vault-recall` under Read.
- `docs/skills/vault-recall.md` reference card; index gains the skill
  under Sessions.
- `docs/skills/vault-carry.md` and `docs/skills/vault-lint.md` gain
  `vault-recall` in their Related sections.

### Design notes
- **List mode is the default** so the agent context stays lean.
  Summaries only, not full file contents. Drilling into a session is an
  explicit `full <slug>` action.
- **Scope filtering is prefix-based.** `/vault-recall projects/agentwatch`
  pulls sessions from any module under that project. `/vault-recall
  projects/agentwatch/agentwatch-push-proxy` narrows to one module.
- **Large artifact loads ask first.** If a `full` load's artifacts
  exceed 50KB combined, the skill lists them with sizes and lets RM
  pick which to load.
- **Detection failures ask** instead of guessing. Claude desktop has no
  working-directory project context — the skill asks for scope.
- **Suggestions, not auto-promotion.** When a loaded session contains a
  decision or a carried reference worth promoting, the skill mentions
  it in a one-line footer but never auto-invokes `vault-logger` or
  `vault-ingest`.

## [1.3.0] — 2026-06-02

Session capture — carry chat working context into the vault.

Discussions in chat (Claude desktop, Claude Code) often produce a
working thread: a summary worth keeping, artifacts (code, diagrams,
documents), and references (URLs, vault links, repo file paths). Until
now, that thread either had to be promoted piece-by-piece via
`vault-logger` or dumped as loose files into a project repo. The carry
skill captures the whole thread as a single dated folder under
`sessions/`, with subfolders for artifacts and references, and a
flexible scope (project / idea / brand / research / general).

### Skills
- `vault-carry` — captures a chat session into `sessions/{YYYY-MM-DD}-{slug}/`
  with `SESSION.md` + `artifacts/` + `references/`. Discusses the
  proposal with RM before writing (slug, scope, what's an artifact
  vs. a link-only reference). Updates `sessions/_INDEX.md`. Never
  modifies project files or auto-promotes content.

### Commands
- `/vault-carry`

### Documentation
- README: new "Capturing chat sessions" workflow section, vault structure
  diagram updated to include `sessions/`, skill table extended, operation
  coverage matrix extended with the Sessions surface.
- `docs/skills/`: per-skill reference card for `vault-carry`; index gains
  a Sessions section.

### Modified
- `vault-lint` gains Check 9: stale active sessions (`status: active`
  and `date:` >60 days old in `sessions/`). Read-only; flags for manual
  archival to `sessions/_archive/`.

### Vault changes (separate from the plugin)
- New top-level `sessions/` folder with `_archive/` subfolder
- `sessions/_INDEX.md` master catalog with Active and Archived tables
- `sessions/_archive/README.md` describing the archive convention
- `AGENTS.md` updated to v1.4 with a Sessions section

### Design notes
- Sessions are **flexibly scoped** via a single `scope:` field that maps
  to a vault path (`projects/X`, `ideas/X`, `brand/X`,
  `research/topics/X`, or `general`). Not every session ties to a project.
- Sessions stay **opt-in for IDE context.** `vault-project-sync` does
  not auto-include sessions in `CLAUDE.md`. From a project repo, ask the
  agent to *load recent sessions for this project* when you want them.
- Sessions never auto-promote. A decision in a session can be logged
  with `vault-logger`; a carried reference can be ingested with
  `vault-ingest`; both are explicit follow-ups.

## [1.2.0] — 2026-06-02

Research layer support — the LLM Wiki pattern applied to the vault.

The vault now has a top-level `research/` folder for accumulating
external material (articles, framework docs, technical analyses, your
own notes) and turning it into LLM-maintained topic synthesis pages.
Ingest extracts key claims from a source and integrates them into one
or more `research/topics/{slug}.md` pages, cross-linked with projects
where relevant. Lint surfaces drift as the vault grows.

### Skills
- `vault-ingest` — process a source from `research/sources/` into one
  or more topic synthesis pages. Discusses proposed topic targets with
  RM before writing (Step 2 is collaborative by design). Updates the
  topic page, the research index row, and appends to the ingest log.
  Never edits the source or project files.
- `vault-lint` — read-only diagnostic pass across eight checks: orphan
  pages, missing topic pages, stale topics, unresolved source
  conflicts, issues missing prevention, pending-review backlog,
  `AGENTS.md` table drift, and broken `[[wikilinks]]`. Suggests, never
  decides.

### Commands
- `/vault-ingest`, `/vault-lint`

### Documentation
- README: new "Research workflow" section, vault structure diagram
  updated to include `research/`, skill table extended, operation
  coverage matrix extended with the Research surface.
- `docs/skills/`: per-skill reference cards for ingest and lint;
  index gains a Research section.

### Vault changes (separate from the plugin)
- New `research/` folder created in the vault with
  `sources/{articles,docs,analyses,notes}/`, `topics/`, and
  `_logs/INGEST_LOG.md`
- `research/_INDEX.md` topic catalog
- README files in each `research/sources/*` subdirectory explaining
  what belongs where
- `AGENTS.md` updated to v1.3 with a Research Library section

## [1.1.0] — 2026-06-02

Complete the agent operation surface — every vault area now has create,
read, update, and lifecycle coverage.

### Skills
- `vault-review` — apply RM's review decisions (`[APPROVED]` /
  `[DISCARDED]` / `[DEFER]`) to pending entries from chat, closing the
  review loop without Obsidian. Applies only decisions RM states; uses
  the same schema-preserving marker-flip pattern as the promoter.
- `vault-read` — return the full content of a resolved file or entry
  (read-only; complements `vault-find`'s snippets).
- `vault-edit` — make a direct, in-place edit to existing vault content.
  Gated: confirms a before → after, then records the change as a
  `[PROMOTED]` context entry for traceability.
- `vault-idea-status` — advance an idea's lifecycle status and move it
  between active/parked/archived sections.
- `vault-project-status` — set a project's status across `PROGRESS.md`,
  `_INDEX.md`, and `AGENTS.md`; archiving relocates the folder to
  `projects/_archive/` (never deletes).
- `vault-move` — rename a project or relocate a module, repointing
  `_INDEX.md`, `AGENTS.md`, `.project-paths`, parent OVERVIEWs, and every
  `[[wikilink]]`; refuses to overwrite or nest deeper than one level.

### Commands
- `/vault-review`, `/vault-read`, `/vault-edit`, `/vault-idea`,
  `/vault-project-status`, `/vault-move`

### Documentation
- README: operation-coverage matrix, review-gated design note, chat-side
  review in the workflow, `_archive/` in the structure diagram

## [1.0.0] — 2026-06-02

Initial release.

### Skills
- `vault-logger` — append entries to pending review log
- `vault-promoter` — move approved entries to destination files
  - Includes schema-preserving marker-flip pattern (two-line anchor)
    to prevent field corruption during status changes
- `vault-status` — read-only summary of vault state
- `vault-project-init` — create new projects/modules from template
- `vault-project-sync` — generate agent files for project repos
- `vault-find` — keyword search across the vault
- `vault-log-archive` — archive promoted/discarded entries monthly

### Commands
- `/vault-log`, `/vault-promote`, `/vault-status`, `/vault-init`,
  `/vault-sync`, `/vault-find`, `/vault-archive`

### Documentation
- README with installation, configuration, and workflow
- This changelog
- LICENSE (MIT)
