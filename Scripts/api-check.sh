#!/bin/sh
# Compare the Qeetrix module's public API with Documentation/API/Qeetrix.public-api.txt.
#
#   Scripts/api-check.sh            fail if the public API changed
#   Scripts/api-check.sh --update   accept the current API (then note the change in CHANGELOG.md)
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
swift package dump-symbol-graph --minimum-access-level public >/dev/null
graphs=$(dirname "$(find .build -path '*symbolgraph*' -name 'Qeetrix.symbols.json' | head -n 1)")
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen api --root "$root" --symbol-graphs "$graphs" "$@"
