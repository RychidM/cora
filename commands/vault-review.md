---
description: Apply review decisions to pending log entries (approve/discard/defer).
skill: vault-review
---

Use the `vault-review` skill to flip `[PENDING]` entries in
`_logs/PENDING_REVIEW.md` to `[APPROVED]`, `[DISCARDED]`, or `[DEFER]`
based on RM's stated decision — closing the review loop from chat.

Argument: the decision and which entries it applies to, e.g.
- `/vault-review approve all pending`
- `/vault-review discard the last entry`
- `/vault-review approve the agentwatch ones`

Only applies decisions RM states. Confirms before broad changes. Run
`/vault-promote` afterward to file approved entries.
