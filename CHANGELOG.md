# Changelog

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
