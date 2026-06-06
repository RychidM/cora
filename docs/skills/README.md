# Skills Reference

One reference card per skill. Each card is a quick lookup — purpose,
command and arguments, trigger phrases, which files it reads and writes,
the rules that matter, and related skills.

The authoritative behavior for each skill lives in its
`skills/{id}/SKILL.md`. These cards summarise; the SKILL.md governs.

---

## Capture & review loop

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-logger](vault-logger.md) | `/vault-log` | Append a `[PENDING]` entry to the review log |
| [vault-review](vault-review.md) | `/vault-review` | Flip pending entries to approved/discarded/deferred |
| [vault-promoter](vault-promoter.md) | `/vault-promote` | Move `[APPROVED]` entries to their destinations |
| [vault-log-archive](vault-log-archive.md) | `/vault-archive` | Move promoted/discarded entries to monthly archives |

## Reading

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-status](vault-status.md) | `/vault-status` | Summarise projects, issues, pending counts |
| [vault-find](vault-find.md) | `/vault-find` | Ranked snippet search across the vault |
| [vault-read](vault-read.md) | `/vault-read` | Full content of one file or entry |

## Editing & lifecycle

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-edit](vault-edit.md) | `/vault-edit` | Direct in-place edit of existing content |
| [vault-idea-status](vault-idea-status.md) | `/vault-idea` | Advance an idea's lifecycle status |
| [vault-project-status](vault-project-status.md) | `/vault-project-status` | Set project status / archive a project |

## Projects setup

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-project-init](vault-project-init.md) | `/vault-init` | Scaffold a new project or module |
| [vault-project-sync](vault-project-sync.md) | `/vault-sync` | Write agent files into a project repo |
| [vault-move](vault-move.md) | `/vault-move` | Rename a project or relocate a module |

## Research

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-ingest](vault-ingest.md) | `/vault-ingest` | Process a source into topic synthesis pages |
| [vault-lint](vault-lint.md) | `/vault-lint` | Diagnostic pass: orphans, stale topics, drift, conflicts |

## Sessions

| Skill | Command | One-liner |
|-------|---------|-----------|
| [vault-carry](vault-carry.md) | `/vault-carry` | Capture a chat session (summary + artifacts + references) into `sessions/` |
| [vault-recall](vault-recall.md) | `/vault-recall` | Load recent sessions back into the current agent context |
| [vault-resume](vault-resume.md) | `/vault-resume` | Pick up any past session in a fresh chat (no project context assumed) |

---

## Shared conventions

Several behaviors are common to every skill:

- **Vault-root resolution** — `$AGENT_MEMORY_VAULT` → Filesystem MCP
  allowed dir → `~/obsidian-memory-vault`.
- **Status semantics** — `[PENDING]` / `[APPROVED]` / `[PROMOTED]` /
  `[DISCARDED]` / `[DEFER]` on log entries.
- **Schema-preserving marker-flip** — status changes anchor on the
  `summary:` + `status:` two-line pattern, one flip per edit.
- **One-level nesting** — projects nest at most one deep
  (`projects/{parent}/{module}/`).
- **Never delete** — write skills append, transform in place, or
  relocate; they never destroy content.

Read-only skills (`vault-status`, `vault-find`, `vault-read`) never write.
