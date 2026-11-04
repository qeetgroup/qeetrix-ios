#!/bin/sh
# Regenerate everything derived from the upstream snapshot (Upstream/, written by sync-upstream.sh
# from the pinned @qeetrix/tokens, @qeetrix/icons and @qeetrix/react): Sources/Qeetrix/Tokens/Generated,
# Sources/Qeetrix/Icons/Generated, Resources/Metadata/token-provenance.json,
# docs/tokens.md and docs/token-values.json.
# Offline and deterministic.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen generate --root "$root"
