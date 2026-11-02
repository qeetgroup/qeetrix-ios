#!/bin/sh
# The dependency and licence gate: every pin in Package.resolved is on Tools/dependency-allowlist.json at
# its reviewed version and licence, the Qeetrix library itself depends on nothing, and every action the
# CI workflows use is pinned to a full commit. Resolves first (networked the first time), so each
# package's licence file can be read.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
swift package resolve >/dev/null
manifest=$(mktemp)
trap 'rm -f "$manifest"' EXIT
swift package dump-package >"$manifest"
swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen dependencies --root "$root" --manifest "$manifest" \
    --checkouts "$root/.build/checkouts"

# A tag can be moved to other code; a commit can't.
unpinned=$(grep -nE '^[[:space:]-]*uses:' .github/workflows/*.yml | grep -vE 'uses:[[:space:]]*[^@[:space:]]+@[0-9a-f]{40}([[:space:]]|$)' || true)
if [ -n "$unpinned" ]; then
    printf '✗ Workflow actions not pinned to a full commit:\n%s\n' "$unpinned" >&2
    exit 1
fi
echo "✓ Workflow actions are pinned to commits."
