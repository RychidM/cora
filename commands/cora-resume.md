---
description: Resume a past session from the vault into a fresh chat, no project context assumed.
skill: cora-resume
---

Use the `cora-resume` skill to pick up a previous chat session inside
the current chat. Unlike `/cora-recall`, it makes no assumption that
you're working in a project — it spans every scope.

Invocations:
- `/cora-resume` — list the most recent sessions across all scopes,
  then load the one you pick in full
- `/cora-resume <query>` — match a session by slug or keyword; loads it
  directly if unique, otherwise lists candidates to choose from
- Add `--limit N` to change how many browse-mode lists (default 5, max 15)
- Add `--include-archived` to include `sessions/_archive/`

Read-only — never modifies any vault file.
