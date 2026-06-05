---
description: Health-check the vault for contradictions, orphans, stale topics, and drift.
skill: vault-lint
---

Use the `vault-lint` skill to scan the vault and produce a diagnostic
report. Read-only — never writes to any file.

No arguments. Optionally takes a focus area:
- `/vault-lint orphans` — only orphan-page check
- `/vault-lint stale` — only stale-topic check
- `/vault-lint drift` — only AGENTS.md table check

If no focus given, run all checks.
