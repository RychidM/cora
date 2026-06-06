# vault-logger

Persist an entry to the vault via propose-then-write — no pending-review queue.

| | |
|---|---|
| **Command** | `/vault-log` |
| **Mode** | Write (propose inline → approve → write to destination) |
| **SKILL.md** | `skills/vault-logger/SKILL.md` |

## Triggers

"log this", "save this to my vault", "note this down", "remember this",
"capture this", "log it".

## Inputs

Inferred from the conversation (asks only if genuinely ambiguous):

- `type` — `idea` / `decision` / `issue` / `resolution` / `progress` / `context`
- `project` — exact vault project name, or `general`
- `domain` — only for `type: idea`: `technical` / `product` / `content` / `business`
- `summary` — one specific line

## How it works

1. Resolve the **primary destination** from the type (`ISSUES.md`,
   `PROGRESS.md`, `OVERVIEW.md`, `ideas/{domain}.md`, …).
2. Resolve **cross-module impact** — submodule writes add an implicit
   breadcrumb to the parent's `ACTIVITY.md`, plus a breadcrumb to each
   sibling listed in `affects:`.
3. **Propose the full draft inline** — every touched file shown, batched
   into one proposal.
4. **Write only after RM's explicit approval**, in one pass.

## Reads / writes

- **Writes:** the resolved destination file in its native format, plus any
  parent/sibling `ACTIVITY.md` breadcrumbs (creating `ACTIVITY.md` from the
  skeleton if missing). Only after approval.
- No `_logs/PENDING_REVIEW.md`, no `status:` field — inline review is the review.

## Key rules

- Never writes without explicit approval, even small edits.
- Shows the full draft, not a summary.
- One entry per distinct topic.
- `type: idea` requires `domain`; ideas never trigger breadcrumbs.
- `context` writes to `OVERVIEW.md` Notes and never triggers breadcrumbs.
- `type: resolution` names the issue ID it resolves (e.g. "Resolves ISSUE-001").

## Related

For changing existing content instead of capturing new, use
[vault-edit](vault-edit.md). The write protocol mirrors the vault's
`AGENTS.md` (Write Protocol + Cross-Module Awareness) — keep them in sync.
