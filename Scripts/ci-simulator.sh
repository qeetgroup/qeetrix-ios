#!/bin/sh
# Print the identifier of the first available iPhone simulator on an iOS runtime, for xcodebuild's
# -destination. Exits non-zero when there is none (install one with `xcodebuild -downloadPlatform iOS`).
set -eu
id=$(xcrun simctl list devices available | awk '
    /^-- iOS / { ios = 1; next }
    /^-- / { ios = 0; next }
    ios && /iPhone/ && match($0, /\([0-9A-F-]{36}\)/) { print substr($0, RSTART + 1, RLENGTH - 2); exit }')
if [ -z "$id" ]; then
    echo "No available iPhone simulator. Run: xcodebuild -downloadPlatform iOS" >&2
    exit 1
fi
echo "$id"
