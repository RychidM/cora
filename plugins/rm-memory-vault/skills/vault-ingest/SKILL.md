---
name: vault-ingest
description: >
  Ingests a research source (article, doc, analysis, or note) from
  `research/sources/` into RM's memory vault, extracting key claims and
  updating relevant topic synthesis pages in `research/topics/`. Use
  this skill when RM asks to ingest, process, file, or summarise a
  source. Trigger phrases include: "ingest this", "process this
  article", "file this source", "summarise this and add it to my
  research", "add this to topics", "integrate this into the wiki".
  Always actually update the topic pages — do not just summarise back
  to chat.
---

# Vault Ingest

Reads a source file in `research/sources/`, extracts the key claims,
and integrates them into one or more `research/topics/` pages. The
source itself is never modified — it's the immutable input.

This is the workflow that turns scattered reading into compounding
knowledge.

---

## Step 1 — Locate the vault and the source

Resolve vault root (see `vault-logger` Step 1).

Identify the source file from RM's request:
- If RM names a file: use `research/sources/{path}`
- If RM says "the article I just clipped" or similar: list
  `research/sources/articles/` and use the most recently modified file
- If RM doesn't name one and there's no obvious recent source: ask

Read the full source file.

---

## Step 2 — Discuss with RM

Before writing anything, share a brief read-back:

```
Source: {filename}
Type: {article | docs | analysis | notes}
Length: ~{N} words

Key claims I extracted:
1. ...
2. ...
3. ...

Proposed topic page(s): {topic-slug-a}, {topic-slug-b}
  - {topic-slug-a}: NEW (will create)
  - {topic-slug-b}: EXISTS (will update)

Anything to emphasise, deprioritise, or correct before I file it?
```

Wait for RM's response or implicit go-ahead before writing. If RM
says "go ahead" or doesn't object, proceed.

This step is what makes the ingest collaborative — RM stays in
control of emphasis without writing the pages.

---

## Step 3 — Resolve the topic page(s)

For each topic identified:

1. Slugify the topic name to kebab-case
   (e.g. "APNs push notifications" → `apns-push-notifications`)
2. Check if `research/topics/{slug}.md` exists
3. If exists → UPDATE mode
4. If not → CREATE mode

A single source may touch multiple topic pages. Process each one.

---

## Step 4a — CREATE a new topic page

Use this template:

```markdown
---
type: research-topic
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
sources: 1
related: []
projects: []
---

# {Topic Title}

> {One-sentence statement of what this topic covers.}

## Summary

{Two or three paragraphs synthesising what this source teaches about
the topic. Write in your own words — don't quote the source verbatim
beyond short technical strings.}

## Key Claims

- {Claim 1} — see [[../sources/{category}/{filename}]]
- {Claim 2} — see [[../sources/{category}/{filename}]]
- {Claim 3} — see [[../sources/{category}/{filename}]]

## Open Questions

- {Anything the source raised but didn't fully answer}

## Sources

- [[../sources/{category}/{filename}]] — added YYYY-MM-DD
```

After creating, add a row to `research/_INDEX.md`:

```
| [[topics/{slug}]] | {one-line summary} | 1 | YYYY-MM-DD |
```

---

## Step 4b — UPDATE an existing topic page

1. Read the existing topic page
2. Identify where each new claim fits:
   - Reinforces an existing claim → add the new source citation
   - Contradicts an existing claim → flag explicitly in the page:
     > ⚠ **Source conflict:** {existing claim from source A} vs
     > {new claim from source B}. Needs resolution.
   - Introduces a new claim → add to Key Claims
   - Raises a new question → add to Open Questions
3. Rewrite the **Summary** section so it incorporates the new source
   — don't just append; rework the prose so it reflects the full
   picture
4. Add the new source to the **Sources** list with the date
5. Update frontmatter: `last_updated`, increment `sources` count
6. Update the row in `research/_INDEX.md`

**Critical:** the Summary is a synthesis, not an append-only log.
Every update should leave the Summary reading as if it were written
in one pass with full knowledge of all sources.

---

## Step 5 — Cross-link to projects

If the source content is relevant to an active project:

1. Identify the project (e.g. APNs work → `agentwatch-push-proxy`)
2. Add the project link to the topic page's frontmatter
   `projects: [[projects/agentwatch/agentwatch-push-proxy/OVERVIEW]]`
3. **Do NOT** edit the project file from this skill — that's the
   job of `vault-logger` + RM's review. Instead, surface the
   connection in the report so RM can decide whether to log it.

---

## Step 6 — Append to the ingest log

Append to `research/_logs/INGEST_LOG.md`:

```
## [YYYY-MM-DD] {source filename}

**Source:** `research/sources/{category}/{filename}.md`
**Topics touched:** [[research/topics/{slug-a}]], [[research/topics/{slug-b}]]
**Projects linked:** [[projects/.../OVERVIEW]] (optional)

{One-paragraph summary of what was learned and what changed.}
```

---

## Step 7 — Report

```
Ingested: {filename}

Updated:
- topics/{slug-a}.md ({new | +N claims, +1 source})
- topics/{slug-b}.md ({new | +N claims, +1 source})

Project relevance:
- {project} — consider logging this as context: "{suggested entry}"

Ingest log: appended.
```

Keep the report scannable. Don't paste back the full topic pages.

---

## Rules

- **Never modify the source file.** It's immutable from the moment
  it lands in `research/sources/`.
- **Always discuss before writing** — Step 2 isn't optional. It's how
  RM stays in control of the synthesis.
- **Rewrite Summary sections in full** on every update — they
  should never read as a stack of appended paragraphs.
- **Cite every claim** with a link to its source.
- **Flag source conflicts explicitly** — don't silently pick one
  side or average them.
- **Update `_INDEX.md` row** for the topic (every create and every
  update changes the count or date).
- **Append to `INGEST_LOG.md` last** — only after all topic pages
  are successfully written.
- **Don't edit project files.** Surface project relevance in the
  report; let RM decide whether to log it.
