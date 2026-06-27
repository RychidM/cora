<!--
Thanks for contributing to CORA! Keep the summary tight and tick the
checklist items that apply. See CONTRIBUTING.md for the full workflow.
-->

## What & why

<!-- What does this change, and why? Link any related issue (e.g. Closes #12). -->

## Type of change

- [ ] New skill / command
- [ ] Change to an existing skill / command
- [ ] Docs only
- [ ] Manifest / packaging / CI
- [ ] Bug fix

## Affected agents

<!-- Which agent surfaces did you touch and test? -->

- [ ] Claude Code / Claude Desktop
- [ ] GitHub Copilot CLI
- [ ] Gemini CLI
- [ ] OpenAI Codex

## Checklist

- [ ] Skills are edited only in the canonical `skills/` — I did **not** hand-edit `plugins/cora/skills/`.
- [ ] If I changed `skills/`, I ran `scripts/sync-codex-skills.sh` and committed the regenerated mirror.
- [ ] Each new/renamed skill's `name:` frontmatter matches its directory name.
- [ ] New or renamed commands have **both** files: `commands/<name>.md` (Claude/Copilot) and `commands/<name>.toml` (Gemini).
- [ ] Added or updated the matching `docs/skills/<name>.md` reference page.
- [ ] If releasing: bumped the `version` in all six manifests and added a `CHANGELOG.md` entry; `scripts/check-release-versions.sh` passes.
- [ ] Voice is consistent — instruction files (skills/commands/docs) address the agent and call its principal "the user"; README addresses the reader as "you".
