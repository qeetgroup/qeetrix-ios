#!/bin/sh
# Regenerate everything derived from the upstream snapshot: Sources/Qeetrix/Tokens/Generated,
# Sources/Qeetrix/Icons/Generated, Resources/Metadata/token-provenance.json and
# Documentation/Foundations/TOKEN_COVERAGE.md. Offline and deterministic.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen generate --root "$root"
