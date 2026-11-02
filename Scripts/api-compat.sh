#!/bin/sh
# Source compatibility of the Qeetrix product against a baseline revision, with Swift's own checker
# (swift package diagnose-api-breaking-changes). Breaks a decision record accepted are listed, verbatim,
# in Documentation/API/breaking-changes-allowlist.txt; any other break fails.
#
#   Scripts/api-compat.sh origin/main     compare with main
#   Scripts/api-compat.sh 10b365f         compare with a commit
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
baseline=${1:?usage: Scripts/api-compat.sh <baseline revision>}
cd "$root"
exec swift package diagnose-api-breaking-changes "$baseline" --products Qeetrix \
    --breakage-allowlist-path Documentation/API/breaking-changes-allowlist.txt
