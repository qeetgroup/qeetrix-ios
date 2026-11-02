#!/bin/sh
# Fetch the npm packages pinned in Upstream/pins.json — @qeetrix/tokens (the DTCG build, tokens.css
# and the native TTFs), @qeetrix/icons (the pinned icons' SVG files and manifest entries) and
# @qeetrix/react (the component manifest and the pinned families' CSS) — verify them against the
# registry's integrity hashes and the fonts against native.json, and rewrite
# Upstream/upstream.lock.json. The only step that touches the network.
#
#   Scripts/sync-upstream.sh           refresh the snapshot and lock
#   Scripts/sync-upstream.sh --check   compare upstream with the lock; change nothing
#
# After a sync, run Scripts/generate.sh.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen sync --root "$root" "$@"
