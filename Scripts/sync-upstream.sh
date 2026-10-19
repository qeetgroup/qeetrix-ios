#!/bin/sh
# Fetch the upstream artifacts pinned in Upstream/pins.json — @qeetrix/ui from npm, the native
# fonts from their releases, the icon drawings from qeetrix-icons — verify them, and rewrite
# Upstream/upstream.lock.json. The only step that touches the network.
#
#   Scripts/sync-upstream.sh           refresh the snapshot and lock
#   Scripts/sync-upstream.sh --check   compare upstream with the lock; change nothing
#
# After a sync, run Scripts/generate.sh.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen sync --root "$root" "$@"
