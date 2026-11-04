#!/bin/sh
# Source compatibility of the Qeetrix product against a baseline revision, with Swift's own checker
# (swift package diagnose-api-breaking-changes). Under SemVer only a new major version may break the API
# (a new minor while 0.x), so the check is skipped when VERSION raises it over the baseline's.
#
#   Scripts/api-compat.sh origin/main     compare with main
#   Scripts/api-compat.sh 0.1.0           compare with a release
set -eu
cd "$(dirname "$0")/.."
baseline=${1:?usage: Scripts/api-compat.sh <baseline revision>}
new=$(cat VERSION)
old=$(git show "$baseline:VERSION" 2>/dev/null || true)
if [ -n "$old" ]; then
    new_major=${new%%.*} old_major=${old%%.*}
    rest=${new#*.} && new_minor=${rest%%.*}
    rest=${old#*.} && old_minor=${rest%%.*}
    if [ "$new_major" -gt "$old_major" ] || { [ "$new_major" -eq 0 ] && [ "$new_minor" -gt "$old_minor" ]; }; then
        echo "✓ $new may break the API of $old: source compatibility not checked."
        exit 0
    fi
fi
exec swift package diagnose-api-breaking-changes "$baseline" --products Qeetrix
