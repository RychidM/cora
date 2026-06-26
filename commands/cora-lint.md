---
description: Health-check the vault for contradictions, orphans, stale topics, and drift.
skill: cora-lint
---

Use the `cora-lint` skill to scan the vault and produce a diagnostic
report. Read-only — never writes to any file.

No arguments. Optionally takes a focus area:
- `/cora-lint orphans` — only orphan-page check
- `/cora-lint stale` — only stale-topic check
- `/cora-lint drift` — only AGENTS.md table check

If no focus given, run all checks.
