---
description: Rename a project or relocate a module, fixing all references.
skill: vault-move
---

Use the `vault-move` skill to rename a project or move a module within
the vault, repointing `_INDEX.md`, `AGENTS.md`, `.project-paths`, parent
OVERVIEWs, and every `[[wikilink]]` that targets it.

Argument: the move, e.g.
- `/vault-move rename agentwatch to agentscope`
- `/vault-move move foo module under bar`
- `/vault-move make foo top-level`

Confirms resolved source/destination and the wikilink rewrite list before
moving. Never overwrites; nesting stays one level deep. Re-run
`/vault-sync` afterward for affected repos.
