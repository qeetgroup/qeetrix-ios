#!/bin/sh
# Build the DocC documentation (Sources/Qeetrix/Qeetrix.docc plus every public doc comment) for iOS,
# treating any DocC warning — a broken symbol link, an undocumented parameter — as an error. Needs Xcode.
#
#   Scripts/docs.sh     prints the path of the built .doccarchive (open it in Xcode)
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
xcodebuild docbuild -quiet -scheme Qeetrix -destination 'generic/platform=iOS' -derivedDataPath .build/docs \
    OTHER_DOCC_FLAGS="--warnings-as-errors"
find .build/docs/Build/Products -name 'Qeetrix.doccarchive' -maxdepth 2 | head -n 1
