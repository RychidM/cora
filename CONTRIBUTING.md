# Contributing to CORA

Thanks for your interest in CORA (Continuity Of Recorded Activity) — a
multi-agent plugin (Claude Code, Claude Desktop, GitHub Copilot CLI, Gemini
CLI, OpenAI Codex) that exposes an Obsidian-based memory vault to any agent.

This guide covers how the repo is laid out, how to make a change, and how
releases work. For what the plugin *does*, see the [README](README.md).

---

## Ground rules

- **Skills are instructions, not code.** Each skill is a `SKILL.md` document
  an agent reads and executes with its own file tools. There is no runtime to
  build or tests to run — correctness is "does an agent do the right thing
  when it reads this." Be precise and unambiguous.
- **One concern per PR.** A new skill, a doc fix, and a version bump are three
  PRs, not one.
- **Match the surrounding style.** Mirror the voice, structure, and naming of
  the files you're editing rather than introducing a new convention.

---

## Repository layout

| Path | What it is |
|------|------------|
| `skills/<name>/SKILL.md` | **Canonical** skill instructions (15 skills). |
| `commands/<name>.md` | Slash-command entry for Claude & Copilot. |
| `commands/<name>.toml` | Slash-command entry for Gemini. |
| `docs/skills/<name>.md` | Human-facing reference page per skill. |
| `plugins/cora/skills/` | **Generated** Codex mirror — never hand-edit. |
| `plugin.json`, `.claude-plugin/`, `.github/plugin/`, `gemini-extension.json`, `plugins/cora/.codex-plugin/`, `.agents/plugins/` | Per-agent manifests / marketplace files. |
| `scripts/` | `sync-codex-skills.sh`, `check-release-versions.sh`. |
| `CHANGELOG.md` | Source of truth for the released version. |

Every skill has a matching command (both `.md` and `.toml`) and a matching
`docs/skills/` page. Keep those three in sync.

---

## Voice & naming conventions

- Skills, commands, and docs share the `cora-` prefix; a skill directory, its
  `name:` frontmatter, its command files, and its docs page all use the same
  base name (e.g. `cora-logger`).

---

## The Codex mirror — read this before touching `skills/`

Codex's `plugin add` copies the plugin directory into a cache and does **not**
follow symlinks or paths outside the plugin root, so the Codex plugin needs a
real in-tree copy of the skills. That copy lives at `plugins/cora/skills/` and
is **generated**.

**Workflow:** edit only the canonical `skills/`, then regenerate the mirror:

```bash
./scripts/sync-codex-skills.sh
```

Commit both the canonical change and the regenerated mirror together. Never
hand-edit `plugins/cora/skills/` — your change will be wiped on the next sync.

---

## Adding or changing a skill

1. Create or edit `skills/<name>/SKILL.md`. Set `name: <name>` in the
   frontmatter to exactly match the directory.
2. Add the command pair so every agent can invoke it:
   - `commands/<name>.md` (Claude / Copilot)
   - `commands/<name>.toml` (Gemini)
   Copy an existing pair as a starting point.
3. Add a reference page at `docs/skills/<name>.md`.
4. Run `./scripts/sync-codex-skills.sh` to refresh the Codex mirror.
5. Install the plugin locally and exercise the skill on the agents you can
   reach (see [local development](#local-development)).

## Adding or changing a command only

Edit both `commands/<name>.md` and `commands/<name>.toml` so behavior stays
consistent across agents. If the change implies a behavior change in the
underlying skill, update the `SKILL.md` (and re-sync the mirror) too.

---

## Local development

Install from your clone instead of the marketplace. From the repo root:

```bash
# Claude — symlink the repo into the plugins dir
ln -s "$(pwd)" ~/.claude/plugins/cora

# Copilot / Codex / Gemini — use the marketplace / link commands from the
# README's Installation section with a local path, e.g.
gemini extensions link .
codex plugin marketplace add .
```

See the README's [From this repository (local dev)](README.md#from-this-repository-local-dev)
section for the full per-agent commands.

Then trigger the skill by natural phrase or its `/cora-*` command and confirm
the agent reads/writes the vault as intended. Test against every agent surface
your change affects.

---

## Versioning & releases

CORA uses [semantic versioning](https://semver.org/). Renaming or removing a
command is **breaking** (major); new skills/commands are **minor**; wording and
fixes are **patch**.

A release touches several files that must agree:

1. Update `CHANGELOG.md` — add a `## [X.Y.Z] — YYYY-MM-DD` entry at the top.
2. Bump `version` to the same `X.Y.Z` in **all six** manifests:
   - `plugin.json`
   - `.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json` (`plugins[0].version`)
   - `.github/plugin/marketplace.json` (`plugins[0].version`)
   - `gemini-extension.json`
   - `plugins/cora/.codex-plugin/plugin.json`
3. Verify they agree:

   ```bash
   ./scripts/check-release-versions.sh
   ```

   This script also runs in CI (`.github/workflows/release-check.yml`) on every
   push to `main` and on `v*` tags — a mismatch fails the build.

---

## Submitting a PR

1. Branch off `main`.
2. Make your change; run `sync-codex-skills.sh` and/or
   `check-release-versions.sh` if they apply.
3. Open a PR and fill in the template.
4. Keep the PR focused and the summary clear about what changed and why.

By contributing you agree your work is licensed under the project's
[MIT License](LICENSE).