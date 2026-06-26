---
description: Set a project's lifecycle status, or archive a finished project.
skill: cora-project-status
---

Use the `cora-project-status` skill to update a project's status across
`PROGRESS.md`, `projects/_INDEX.md`, and `AGENTS.md` — or to archive a
finished/abandoned project by relocating it to `projects/_archive/`
(never deleting it).

Argument: the project and its new state, e.g.
- `/cora-project-status mark agentwatch active`
- `/cora-project-status set foo to paused`
- `/cora-project-status archive the bar project`

Matches the existing status vocabulary. Confirms before archiving.
