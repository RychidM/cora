# Changelog

## [1.0.0] — 2026-06-27

First release of **CORA** (Continuity Of Recorded Activity) — the companion
controls for [cora-vault](https://github.com/RychidM/cora-vault). 15 skills,
each with a slash command, that let any supported agent operate the memory
vault directly from chat.

### Agents
- Claude Code, Claude Desktop, GitHub Copilot CLI, Gemini CLI, and OpenAI Codex.

### Capturing knowledge
- `cora-logger` (`/cora-log`) — **propose-then-write**: resolves the
  destination from the entry type, shows the full draft of every file it will
  touch, and writes all destinations in one pass on approval. No pending-review
  queue. Owns cross-module awareness — project writes add to the project's
  `ACTIVITY.md`; submodule writes breadcrumb to the parent and to siblings
  named in `affects:`.
- `cora-ingest` (`/cora-ingest`) — process a source from `research/sources/`
  into one or more LLM-maintained `research/topics/` synthesis pages,
  cross-linked to projects. Discusses topic targets before writing; never
  edits the source.
- `cora-carry` (`/cora-carry`) — capture a chat session into
  `sessions/{date}-{slug}/` with `SESSION.md`, `artifacts/`, and
  `references/`.

### Reading & search
- `cora-find` (`/cora-find`) — keyword search across the vault.
- `cora-read` (`/cora-read`) — return the full content of a resolved file or
  entry.
- `cora-status` (`/cora-status`) — read-only summary of vault state and recent
  activity.
- `cora-recall` (`/cora-recall`) — project-bound session recall; auto-detects
  the current project and loads a session back into context.
- `cora-resume` (`/cora-resume`) — scope-agnostic session resume; browse
  recent sessions across all scopes from a fresh chat and continue one.

### Editing & lifecycle
- `cora-edit` (`/cora-edit`) — direct, gated in-place edits to existing vault
  content (confirms before → after).
- `cora-move` (`/cora-move`) — rename a project or relocate a module,
  repointing `_INDEX.md`, `AGENTS.md`, `.project-paths`, parent OVERVIEWs, and
  every `[[wikilink]]`; keeps `parent:`/`submodules:` frontmatter in sync.
- `cora-idea-status` (`/cora-idea`) — advance an idea's lifecycle status.
- `cora-project-status` (`/cora-project-status`) — set a project's status;
  archiving relocates the folder to `projects/_archive/` (never deletes).

### Projects
- `cora-project-init` (`/cora-init`) — scaffold a new project or module from
  `_TEMPLATE`, register it in the index and `AGENTS.md`, and write the
  `parent:`/`submodules:` frontmatter that declares relationships.
- `cora-project-sync` (`/cora-sync`) — generate per-repo agent files
  (`CLAUDE.md`/`GEMINI.md`/Copilot/Codex instructions) from the vault.

### Health
- `cora-lint` (`/cora-lint`) — read-only diagnostic pass: orphan pages,
  missing/stale topics, unresolved source conflicts, `ACTIVITY.md` health,
  Active Projects table drift, stale sessions, and broken `[[wikilinks]]`.

### Packaging
- Per-agent manifests for Claude (`.claude-plugin/`), Copilot
  (`plugin.json` + `.github/plugin/`), Gemini (`gemini-extension.json`), and
  Codex (`plugins/cora/` with the generated skills mirror).
- Single-source vault resolution via `$AGENT_MEMORY_VAULT` with documented
  fallbacks.
- `CONTRIBUTING.md`, PR template, and a CI version check
  (`scripts/check-release-versions.sh`).
