# vault-move

Rename a project or relocate a module, fixing all references.

| | |
|---|---|
| **Command** | `/vault-move` |
| **Mode** | Write (relocate + reference rewrite) |
| **SKILL.md** | `skills/vault-move/SKILL.md` |

## Triggers

"rename agentwatch to X", "move the foo module under bar", "make this
module top-level", "relocate the X project".

## Operations

- Rename a project (or module).
- Move a module to a different parent.
- Promote a module to top-level.
- Demote a top-level project to a module.

## Reads / writes

- **Reads:** the source folder, `_INDEX.md`, `AGENTS.md`,
  `.project-paths`, and all `*.md` for `[[wikilinks]]`.
- **Writes:** moves the folder, then repoints `_INDEX.md`, `AGENTS.md`,
  the moved/parent OVERVIEWs (including `parent:`/`submodules:`
  frontmatter on both sides), every `[[wikilink]]`, and `.project-paths`.
  Creates/deletes `ACTIVITY.md` when a project is promoted to or demoted
  from top-level.

## Key rules

- Never overwrites — refuses if the destination exists.
- One level of nesting max.
- Moves, never copy-and-delete; never destroys content.
- Fixes **every** reference — a move that leaves dangling links is a
  failed move.
- Keeps `parent:`/`submodules:` frontmatter in sync on both sides.
- Confirms resolved source/destination + the wikilink rewrite list first.
- Flags synced repo files as stale.

## Related

After a move, re-run [vault-project-sync](vault-project-sync.md).
Lifecycle-adjacent to [vault-project-status](vault-project-status.md)
(status/archive vs. rename/relocate).
