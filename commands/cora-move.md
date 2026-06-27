---
description: Rename a project or relocate a module, fixing all references.
skill: cora-move
---

Use the `cora-move` skill to rename a project or move a module within
the vault, repointing `_INDEX.md`, `AGENTS.md`, `.project-paths`, parent
OVERVIEWs, and every `[[wikilink]]` that targets it.

Argument: the move, e.g.
- `/cora-move rename agentwatch to agentscope`
- `/cora-move move foo module under bar`
- `/cora-move make foo top-level`

Confirms resolved source/destination and the wikilink rewrite list before
moving. Never overwrites; nesting stays one level deep. Re-run
`/cora-sync` afterward for affected repos.
