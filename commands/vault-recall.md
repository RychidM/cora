---
description: Recall recent sessions from the vault into the current agent context.
skill: vault-recall
---

Use the `vault-recall` skill to load past sessions from the vault back
into the agent's working context.

Invocations:
- `/vault-recall` — list 3 most recent sessions for the current project
  (auto-detected from working directory)
- `/vault-recall <scope-prefix>` — filter by an explicit scope path
  (e.g. `/vault-recall ideas/content`, `/vault-recall projects/agentwatch`)
- `/vault-recall full <slug>` — load one session in full
  (`SESSION.md` + references; artifacts on request if large)
- Add `--limit N` to change how many list-mode shows (default 3, max 10)
- Add `--include-archived` to include `sessions/_archive/`

Read-only — never modifies any vault file.
