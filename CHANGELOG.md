# Changelog

## [2.1.0] — 2026-06-08

Also aligns the `ACTIVITY.md` model with the companion vault template
(`cora-vault`): it's scaffolded for every top-level
project at creation time, not lazily per write, and modules never get
their own — their activity always rolls up into the parent's feed.

### Added
- Support for Gemini CLI: added `gemini-extension.json` and updated documentation to include Gemini CLI as a supported agent.

### Changed
- `cora-project-init` no longer eagerly creates `ACTIVITY.md` for every
  project/module. Top-level projects keep the copy that now ships in
  `_TEMPLATE/`; modules have it deleted. It also writes the `parent:` /
  `submodules:` frontmatter declaration on both sides of a new module —
  the authoritative source (per `AGENTS.md`) for resolving relationships
  at session start, not folder nesting.
- `cora-move` keeps `parent:`/`submodules:` frontmatter in sync on both
  sides when relocating, promoting, or demoting a project/module, and
  creates/deletes `ACTIVITY.md` accordingly on promotion/demotion.
- `cora-lint` Check 6 (`ACTIVITY.md health`) now also flags modules that
  wrongly have their own feed, and Check 7 (`Active Projects table
  drift`) flags one-sided `parent:`/`submodules:` declarations.
- `cora-status` / `cora-project-init` docs corrected: previously implied
  every project gets an `ACTIVITY.md`; now scoped to top-level only.

### Fixed
- Removed the false assumption (in `cora-status`, `cora-lint`, and
  `cora-project-init`) that every project and module has its own
  `ACTIVITY.md`.

## [2.0.0] — 2026-06-06

**Breaking.** Aligns the plugin with AGENTS.md v2.0: the pending-review
queue is gone, replaced by propose-then-write, and projects gain
cross-module activity feeds. Any agent or workflow built against the
v1.x write contract (appending to `_logs/PENDING_REVIEW.md`, the
`status:` field, the promote step) will no longer work.

### Removed
- `cora-promoter` / `/cora-promote` — no promote step; writes land
  directly on approval.
- `cora-review` / `/cora-review` — inline review replaces queue review.
- `cora-log-archive` / `/cora-archive` — no review log to archive.

### Changed
- `cora-logger` (`/cora-log`) repurposed to **propose-then-write**: it
  resolves the destination from the entry type, shows the full draft of
  every file it will touch, waits for explicit approval, then writes all
  destinations in one batched pass. No `_logs/PENDING_REVIEW.md`, no
  `status:` field.
- `cora-logger` now owns **cross-module awareness**: project-scoped
  `issue`/`resolution`/`progress`/`decision` writes add an entry to the
  project's `ACTIVITY.md`; submodule writes add an implicit breadcrumb to
  the parent and explicit breadcrumbs to siblings named in `affects:`.
- `cora-project-init` scaffolds an empty `ACTIVITY.md` for every new
  project/module (from the skeleton if the template lacks one).
- `cora-lint` Check 6 swapped from "pending review backlog" to
  **ACTIVITY.md health** (missing feeds, stale feeds, orphaned
  breadcrumbs).
- `cora-status` reports **recent activity** across projects instead of
  pending-review counts.
- `cora-edit` no longer self-logs a `[PROMOTED]` context record;
  traceability comes from version history.
- `cora-find` / `cora-read` search/resolve `ACTIVITY.md` and research
  files; dropped the pending-log surface.

### Migration
- Write the final `[APPROVED]` pending entry, then archive
  `_logs/PENDING_REVIEW.md` (done in the vault: moved to
  `_logs/_archive/`).
- Backfill `ACTIVITY.md` for existing projects/modules so session-start
  reads have a target (vault-side; not shipped in the plugin).
- Re-run `/cora-sync` on wired repos so their `CLAUDE.md` reflects the
  v2.0 write protocol.

### Documentation
- README rewritten around propose-then-write and activity/cross-module
  awareness; removed the log → review → promote → archive loop, status
  semantics, and the pending-log surface from the operation matrix.
- `docs/skills/` index and cards updated; removed the three obsolete
  cards.

## [1.5.0] — 2026-06-06

Scope-agnostic session resume — pick up any session in a fresh chat.

`cora-recall` is project-bound: it auto-detects the current project from
the working directory and filters sessions to that scope, which assumes
you're already inside a project. This release adds `cora-resume` for the
other case — opening a brand-new chat with no project context and wanting
to continue a past session.

### Skills
- `cora-resume` — read-only. Browse mode lists the most recent sessions
  across **all** scopes (no project auto-detection, no scope filter),
  RM picks one, and it loads in full. Match mode (`/cora-resume <query>`)
  resolves a session by slug or keyword. Surfaces the session's open
  threads as a "pick up" footer so resuming continues the work rather
  than just previewing it.

### Commands
- `/cora-resume` — browse: list recent sessions (all scopes), load on pick
- `/cora-resume <query>` — match by slug or keyword, load if unique
- Flags: `--limit N` (default 5, max 15), `--include-archived`

### Documentation
- README: skill table extended; Sessions row in the operation coverage
  matrix now lists `cora-resume` under Read; new "Resuming a session in
  a fresh chat" subsection.
- `docs/skills/cora-resume.md` reference card; index gains the skill
  under Sessions.
- `docs/skills/cora-recall.md` and `docs/skills/cora-carry.md` gain
  `cora-resume` in their Related sections.

### Design notes
- **Resume is the scope-agnostic door; recall is the project-bound door.**
  Resume never auto-detects a project or filters by scope — that's the
  one behavioural line that separates the two skills.
- **Browse, then load.** Default behaviour lists and waits for a pick;
  loading is full by default once chosen, since the intent is to continue
  the work.
- **Large artifact loads ask first**, mirroring `cora-recall` (>50KB
  total prompts for selection).

## [1.4.0] — 2026-06-02

Session recall — the counterpart to `cora-carry`.

v1.3.0 captured chat sessions into `sessions/`. This release closes the
loop by adding `cora-recall`, which loads sessions back into agent
context when working in an IDE or chat. The carry/recall pair is the
complete session lifecycle: carry IN, recall OUT.

### Skills
- `cora-recall` — read-only. Lists recent sessions matching a scope
  prefix, or loads one session fully (`SESSION.md` + references; large
  artifacts opt-in). Auto-detects the current project from the working
  directory in Claude Code; asks for scope when detection fails
  (e.g. Claude desktop).

### Commands
- `/cora-recall` — list mode (current project, auto-detected)
- `/cora-recall <scope-prefix>` — list mode with explicit scope
- `/cora-recall full <slug>` — load one session completely
- Flags: `--limit N`, `--include-archived`

### Documentation
- README: skill table extended; Sessions row in the operation coverage
  matrix now lists `cora-recall` under Read.
- `docs/skills/cora-recall.md` reference card; index gains the skill
  under Sessions.
- `docs/skills/cora-carry.md` and `docs/skills/cora-lint.md` gain
  `cora-recall` in their Related sections.

### Design notes
- **List mode is the default** so the agent context stays lean.
  Summaries only, not full file contents. Drilling into a session is an
  explicit `full <slug>` action.
- **Scope filtering is prefix-based.** `/cora-recall projects/agentwatch`
  pulls sessions from any module under that project. `/cora-recall
  projects/agentwatch/agentwatch-push-proxy` narrows to one module.
- **Large artifact loads ask first.** If a `full` load's artifacts
  exceed 50KB combined, the skill lists them with sizes and lets RM
  pick which to load.
- **Detection failures ask** instead of guessing. Claude desktop has no
  working-directory project context — the skill asks for scope.
- **Suggestions, not auto-promotion.** When a loaded session contains a
  decision or a carried reference worth promoting, the skill mentions
  it in a one-line footer but never auto-invokes `cora-logger` or
  `cora-ingest`.

## [1.3.0] — 2026-06-02

Session capture — carry chat working context into the vault.

Discussions in chat (Claude desktop, Claude Code) often produce a
working thread: a summary worth keeping, artifacts (code, diagrams,
documents), and references (URLs, vault links, repo file paths). Until
now, that thread either had to be promoted piece-by-piece via
`cora-logger` or dumped as loose files into a project repo. The carry
skill captures the whole thread as a single dated folder under
`sessions/`, with subfolders for artifacts and references, and a
flexible scope (project / idea / brand / research / general).

### Skills
- `cora-carry` — captures a chat session into `sessions/{YYYY-MM-DD}-{slug}/`
  with `SESSION.md` + `artifacts/` + `references/`. Discusses the
  proposal with RM before writing (slug, scope, what's an artifact
  vs. a link-only reference). Updates `sessions/_INDEX.md`. Never
  modifies project files or auto-promotes content.

### Commands
- `/cora-carry`

### Documentation
- README: new "Capturing chat sessions" workflow section, vault structure
  diagram updated to include `sessions/`, skill table extended, operation
  coverage matrix extended with the Sessions surface.
- `docs/skills/`: per-skill reference card for `cora-carry`; index gains
  a Sessions section.

### Modified
- `cora-lint` gains Check 9: stale active sessions (`status: active`
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
- Sessions stay **opt-in for IDE context.** `cora-project-sync` does
  not auto-include sessions in `CLAUDE.md`. From a project repo, ask the
  agent to *load recent sessions for this project* when you want them.
- Sessions never auto-promote. A decision in a session can be logged
  with `cora-logger`; a carried reference can be ingested with
  `cora-ingest`; both are explicit follow-ups.

## [1.2.0] — 2026-06-02

Research layer support — the LLM Wiki pattern applied to the vault.

The vault now has a top-level `research/` folder for accumulating
external material (articles, framework docs, technical analyses, your
own notes) and turning it into LLM-maintained topic synthesis pages.
Ingest extracts key claims from a source and integrates them into one
or more `research/topics/{slug}.md` pages, cross-linked with projects
where relevant. Lint surfaces drift as the vault grows.

### Skills
- `cora-ingest` — process a source from `research/sources/` into one
  or more topic synthesis pages. Discusses proposed topic targets with
  RM before writing (Step 2 is collaborative by design). Updates the
  topic page, the research index row, and appends to the ingest log.
  Never edits the source or project files.
- `cora-lint` — read-only diagnostic pass across eight checks: orphan
  pages, missing topic pages, stale topics, unresolved source
  conflicts, issues missing prevention, pending-review backlog,
  `AGENTS.md` table drift, and broken `[[wikilinks]]`. Suggests, never
  decides.

### Commands
- `/cora-ingest`, `/cora-lint`

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
- `cora-review` — apply RM's review decisions (`[APPROVED]` /
  `[DISCARDED]` / `[DEFER]`) to pending entries from chat, closing the
  review loop without Obsidian. Applies only decisions RM states; uses
  the same schema-preserving marker-flip pattern as the promoter.
- `cora-read` — return the full content of a resolved file or entry
  (read-only; complements `cora-find`'s snippets).
- `cora-edit` — make a direct, in-place edit to existing vault content.
  Gated: confirms a before → after, then records the change as a
  `[PROMOTED]` context entry for traceability.
- `cora-idea-status` — advance an idea's lifecycle status and move it
  between active/parked/archived sections.
- `cora-project-status` — set a project's status across `PROGRESS.md`,
  `_INDEX.md`, and `AGENTS.md`; archiving relocates the folder to
  `projects/_archive/` (never deletes).
- `cora-move` — rename a project or relocate a module, repointing
  `_INDEX.md`, `AGENTS.md`, `.project-paths`, parent OVERVIEWs, and every
  `[[wikilink]]`; refuses to overwrite or nest deeper than one level.

### Commands
- `/cora-review`, `/cora-read`, `/cora-edit`, `/cora-idea`,
  `/cora-project-status`, `/cora-move`

### Documentation
- README: operation-coverage matrix, review-gated design note, chat-side
  review in the workflow, `_archive/` in the structure diagram

## [1.0.0] — 2026-06-02

Initial release.

### Skills
- `cora-logger` — append entries to pending review log
- `cora-promoter` — move approved entries to destination files
  - Includes schema-preserving marker-flip pattern (two-line anchor)
    to prevent field corruption during status changes
- `cora-status` — read-only summary of vault state
- `cora-project-init` — create new projects/modules from template
- `cora-project-sync` — generate agent files for project repos
- `cora-find` — keyword search across the vault
- `cora-log-archive` — archive promoted/discarded entries monthly

### Commands
- `/cora-log`, `/cora-promote`, `/cora-status`, `/cora-init`,
  `/cora-sync`, `/cora-find`, `/cora-archive`

### Documentation
- README with installation, configuration, and workflow
- This changelog
- LICENSE (MIT)
