---
description: Promote approved entries from the pending review log.
skill: vault-promoter
---

Use the `vault-promoter` skill to find all `[APPROVED]` entries in
`_logs/PENDING_REVIEW.md` and move them to their destination files.

Use the schema-preserving marker-flip pattern (two-line anchor:
`summary:` + `status:`) when changing `[APPROVED]` → `[PROMOTED]`.

If no argument is given, promote all approved entries. If an argument
identifies a specific entry (by summary keyword), promote only that one.
