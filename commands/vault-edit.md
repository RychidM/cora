---
description: Make a direct in-place edit to existing vault content.
skill: vault-edit
---

Use the `vault-edit` skill to apply a surgical edit to content that
already exists in the vault — a project file, an idea, a brand file, or
the index — when the change should land now rather than route through the
review log.

Argument: what to change, e.g.
- `/vault-edit fix the typo in agentwatch STYLE.md`
- `/vault-edit reword the brand profile intro`

This bypasses the review loop, so the skill shows a before → after and
confirms before non-trivial writes, then records the edit as a context
entry in the log. For *new* knowledge, use `/vault-log` instead.
