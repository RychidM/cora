#!/usr/bin/env bash
# Fail if any manifest's "version" field disagrees with CHANGELOG.md's
# newest entry. Run before tagging a release (also wired into CI).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

changelog_version="$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
if [[ -z "$changelog_version" ]]; then
  echo "Could not find a version heading in CHANGELOG.md" >&2
  exit 1
fi

# file:jsonpath — jsonpath is "version" (top-level) or "plugins[0].version"
manifests=(
  "plugin.json:version"
  ".claude-plugin/plugin.json:version"
  ".claude-plugin/marketplace.json:plugins[0].version"
  ".github/plugin/marketplace.json:plugins[0].version"
  "gemini-extension.json:version"
  "plugins/rm-memory-vault/.codex-plugin/plugin.json:version"
)

fail=0
for entry in "${manifests[@]}"; do
  file="${entry%%:*}"
  path="${entry#*:}"

  found="$(python3 -c "
import json
data = json.load(open('$file'))
path = '$path'
if path == 'version':
    print(data.get('version', ''))
elif path == 'plugins[0].version':
    print(data.get('plugins', [{}])[0].get('version', ''))
else:
    raise SystemExit(f'unsupported path: {path}')
")"

  if [[ "$found" != "$changelog_version" ]]; then
    echo "MISMATCH: $file ($path) is '$found', CHANGELOG.md top entry is '$changelog_version'" >&2
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then
  echo "Version check failed." >&2
  exit 1
fi

echo "All manifest versions match CHANGELOG.md ($changelog_version)."
