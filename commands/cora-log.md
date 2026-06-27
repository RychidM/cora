---
description: Log something from the current conversation to the vault.
skill: cora-logger
---

Use the `cora-logger` skill to persist an entry to the vault. Infer the
entry type, project, summary, and details from the current conversation,
resolve the destination file (and any cross-module breadcrumbs), then
propose the full draft inline. Write only after the user approves — there is no
pending-review queue.

Argument hint: anything after `/cora-log` is the topic to log
(e.g. `/cora-log the relay JWT decision`).

If no argument is given, log the most recent decision, idea, issue, or
context from the conversation.
