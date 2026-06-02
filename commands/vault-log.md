---
description: Log something from the current conversation to the vault.
skill: vault-logger
---

Use the `vault-logger` skill to append a structured entry to
`_logs/PENDING_REVIEW.md`. Infer the entry type, project, summary, and
details from the current conversation. Always include
`status: [PENDING]`.

Argument hint: anything after `/vault-log` is the topic to log
(e.g. `/vault-log the relay JWT decision`).

If no argument is given, log the most recent decision, idea, issue, or
context from the conversation.
