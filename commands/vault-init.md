---
description: Initialise a new project or module in the vault.
skill: vault-project-init
---

Use the `vault-project-init` skill to create a new project from the
template, register it in `_INDEX.md` and `AGENTS.md`, and optionally
sync agent files to its repo.

Argument syntax:
- `/vault-init my-project [repo-path]` — top-level project
- `/vault-init agentwatch/my-module [repo-path]` — module under a parent

If parameters are missing, ask before creating files.
