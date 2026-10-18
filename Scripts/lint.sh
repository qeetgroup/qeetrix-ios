#!/bin/sh
# swift-format, strict, over every hand-written Swift file. Generated files are excluded: they carry a
# do-not-edit header and Scripts/verify.sh holds them byte-for-byte to the generator's output.
#
#   Scripts/lint.sh          report
#   Scripts/lint.sh --fix    rewrite in place
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
files=$(find Package.swift Sources Tests Tools/QeetrixGen/Package.swift Tools/QeetrixGen/Sources Tools/QeetrixGen/Tests Examples \
    -name '*.swift' -not -path '*/Generated/*' -not -path '*/.build/*' | sort)
if [ "${1:-}" = "--fix" ]; then
    # shellcheck disable=SC2086
    exec swift format format --in-place $files
fi
# shellcheck disable=SC2086
exec swift format lint --strict $files
