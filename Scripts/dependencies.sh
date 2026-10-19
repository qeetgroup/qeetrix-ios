#!/bin/sh
# The dependency and licence gate: every pin in Package.resolved is on Tools/dependency-allowlist.json at
# its reviewed version and licence, and the Qeetrix library itself depends on nothing. Resolves first
# (networked the first time), so each package's licence file can be read.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
swift package resolve >/dev/null
manifest=$(mktemp)
trap 'rm -f "$manifest"' EXIT
swift package dump-package >"$manifest"
swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen dependencies --root "$root" --manifest "$manifest" \
    --checkouts "$root/.build/checkouts"
