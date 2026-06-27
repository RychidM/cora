#!/usr/bin/env bash
# Mirror the canonical repo-root skills/ into the Codex plugin subdir.
# Codex's `plugin add` copies the plugin directory into a version cache and
# does NOT follow symlinks or paths outside the plugin root, so the Codex
# plugin needs a real, in-tree copy of the skills. Run this after editing
# skills/ and before committing.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/skills"
dest="$root/plugins/cora/skills"
rm -rf "$dest"
mkdir -p "$dest"
cp -R "$src/." "$dest/"
echo "Synced $(find "$src" -name SKILL.md | wc -l | tr -d ' ') skills -> plugins/cora/skills/"
