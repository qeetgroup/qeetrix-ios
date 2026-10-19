#!/bin/sh
# Static analysis: a clean build of the package, its tests and the generator with zero compiler warnings
# in this repository's code — Swift 6 strict concurrency included. Dependencies' own warnings are not
# ours to fix and are ignored. Builds into .build/warnings, from scratch, so no warning is hidden by an
# incremental build.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
log=$(mktemp)
trap 'rm -f "$log"' EXIT
status=0
rm -rf .build/warnings Tools/QeetrixGen/.build/warnings
swift build --build-tests --scratch-path .build/warnings >"$log" 2>&1 || status=$?
swift build --build-tests --package-path Tools/QeetrixGen --scratch-path Tools/QeetrixGen/.build/warnings >>"$log" 2>&1 || status=$?
found=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | grep -E "^$root/(Sources|Tests|Tools/QeetrixGen/(Sources|Tests))/.*: (warning|error):" | sort -u || true)
if [ -n "$found" ] || [ "$status" -ne 0 ]; then
    [ -n "$found" ] && echo "$found"
    [ "$status" -ne 0 ] && tail -n 20 "$log"
    echo "✗ The build has warnings or errors." >&2
    exit 1
fi
echo "✓ No compiler warnings in the package, its tests or the generator."
