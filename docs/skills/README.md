# Skills Reference

One reference card per skill. Each card is a quick lookup — purpose,
command and arguments, trigger phrases, which files it reads and writes,
the rules that matter, and related skills.

The authoritative behavior for each skill lives in its
`skills/{id}/SKILL.md`. These cards summarise; the SKILL.md governs.

---

## Capture

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-logger](cora-logger.md) | `/cora-log` | Propose an entry inline, then write it to its destination on approval (+ cross-module breadcrumbs) |

## Reading

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-status](cora-status.md) | `/cora-status` | Summarise projects, issues, recent activity |
| [cora-find](cora-find.md) | `/cora-find` | Ranked snippet search across the vault |
| [cora-read](cora-read.md) | `/cora-read` | Full content of one file or entry |

## Editing & lifecycle

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-edit](cora-edit.md) | `/cora-edit` | Direct in-place edit of existing content |
| [cora-idea-status](cora-idea-status.md) | `/cora-idea` | Advance an idea's lifecycle status |
| [cora-project-status](cora-project-status.md) | `/cora-project-status` | Set project status / archive a project |

## Projects setup

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-project-init](cora-project-init.md) | `/cora-init` | Scaffold a new project or module |
| [cora-project-sync](cora-project-sync.md) | `/cora-sync` | Write agent files into a project repo |
| [cora-move](cora-move.md) | `/cora-move` | Rename a project or relocate a module |

## Research

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-ingest](cora-ingest.md) | `/cora-ingest` | Process a source into topic synthesis pages |
| [cora-lint](cora-lint.md) | `/cora-lint` | Diagnostic pass: orphans, stale topics, drift, conflicts |

## Sessions

| Skill | Command | One-liner |
|-------|---------|-----------|
| [cora-carry](cora-carry.md) | `/cora-carry` | Capture a chat session (summary + artifacts + references) into `sessions/` |
| [cora-recall](cora-recall.md) | `/cora-recall` | Load recent sessions back into the current agent context |
| [cora-resume](cora-resume.md) | `/cora-resume` | Pick up any past session in a fresh chat (no project context assumed) |

---

## Shared conventions

Several behaviors are common to every skill:

- **Vault-root resolution** — `$AGENT_MEMORY_VAULT` → Filesystem MCP
  allowed dir → `~/obsidian-memory-vault`.
- **Propose-then-write** — writes are proposed inline and land in their
  destination on the user's approval; there is no pending-review queue.
- **Cross-module breadcrumbs** — submodule writes notify the parent
  implicitly and named siblings (`affects:`) explicitly, via `ACTIVITY.md`.
- **One-level nesting** — projects nest at most one deep
  (`projects/{parent}/{module}/`).
- **Never delete** — write skills append, transform in place, or
  relocate; they never destroy content.

Read-only skills (`cora-status`, `cora-find`, `cora-read`) never write.
