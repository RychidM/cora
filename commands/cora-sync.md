---
description: Regenerate agent files and SessionStart hooks for a project repo.
skill: cora-project-sync
---

Use the `cora-project-sync` skill to write fresh agent context files
and per-agent `SessionStart` hooks into a project repo from the vault's
`AGENTS.md`, the project's `OVERVIEW.md`, and the session-start recap.

Argument: a repo path. If not given, use the current working directory
or the path registered for the named project.
