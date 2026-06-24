---
name: vault-status
description: >
  Shows the current state of RM's memory vault — active projects, open
  issues by project, and recent cross-project activity. Use this skill
  when RM asks for vault status, what's open, what's been happening,
  where things stand, or any variation. Trigger phrases include: "vault
  status", "what's in my vault", "what's open", "what's been happening",
  "where do things stand", "vault summary".
---

# Vault Status

Produces a concise summary of the vault: projects with their statuses,
open issue counts, active ideas, and recent activity across projects.

---

## Step 1 — Locate the vault

Resolve vault root (see `vault-logger` Step 1).

---

## Step 2 — Gather information

Read these files and extract the relevant data:

| File | What to extract |
|------|-----------------|
| `projects/_INDEX.md` | Project list with statuses |
| `projects/{p}/ACTIVITY.md` (for each project) | Most recent few entries (date + type + summary) |
| `projects/{p}/ISSUES.md` (for each project) | Count entries under "Open Issues" |
| `projects/{p}/PROGRESS.md` (for each project) | `current_phase` from frontmatter |

For nested module projects, recurse into subdirectories.

---

## Step 3 — Format the output

Produce a single concise markdown report:

```
# Vault Status — {today}

## Projects

| Project | Status | Phase | Open Issues |
|---------|--------|-------|-------------|
| ...     | ...    | ...   | ...         |

## Recent Activity

Most recent entries across all projects' `ACTIVITY.md` feeds, newest first:

- {date} `{project}` [{type}] {summary}
- ...

## Active Ideas

- technical: N
- product: N
- content: N
- business: N
```

---

## Rules

- **Don't speculate** — count from the actual files
- **Don't write to the vault** — this is read-only
- **Keep it scannable** — single screen if possible
- **If a project has no `current_phase` set, show "—" not "unknown"**
