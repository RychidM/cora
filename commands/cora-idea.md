---
description: Advance an idea's lifecycle status in the vault.
skill: cora-idea-status
---

Use the `cora-idea-status` skill to update an idea's `**Status:**` in
`ideas/{domain}.md` and move it between active and parked/archived
sections when warranted.

Argument: the idea and its new state, e.g.
- `/cora-idea mark the offline-sync idea as building`
- `/cora-idea the X idea shipped`
- `/cora-idea park the Y idea`

Matches the file's existing status vocabulary. Confirms before moving an
idea between sections.
