---
description: Regenerate agent files (CLAUDE.md, GEMINI.md, ...) for a project repo.
skill: vault-project-sync
---

Use the `vault-project-sync` skill to write fresh agent context files
into a project repo from the vault's `AGENTS.md` and the project's
`OVERVIEW.md`.

Argument: a repo path. If not given, use the current working directory
or the path registered for the named project.
