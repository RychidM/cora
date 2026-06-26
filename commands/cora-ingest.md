---
description: Ingest a research source into the topic library.
skill: cora-ingest
---

Use the `cora-ingest` skill to read a source from `research/sources/`,
extract key claims, and integrate them into `research/topics/` pages.

Argument: the source filename (or path relative to `research/sources/`).
If omitted, use the most recently modified file in
`research/sources/articles/` and confirm with the user.

Always discuss the proposed topic targets with the user before writing
(Step 2 of the skill).
