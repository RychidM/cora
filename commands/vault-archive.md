---
description: Archive promoted and discarded entries from the pending review log.
skill: vault-log-archive
---

Use the `vault-log-archive` skill to move `[PROMOTED]` and `[DISCARDED]`
entries from `_logs/PENDING_REVIEW.md` into monthly archive files at
`_logs/archive/YYYY-MM.md`.

Never touches `[PENDING]`, `[APPROVED]`, or `[DEFER]` entries.
