#!/bin/sh
# The release's CycloneDX bill of materials, from the pins, the lock, Package.resolved and the dependency
# allowlist. Offline once dependencies are resolved.
#
#   Scripts/sbom.sh <version> [output file]     e.g. Scripts/sbom.sh 0.1.0-rc.1 qeetrix-ios.cdx.json
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
version=${1:?usage: Scripts/sbom.sh <version> [output file]}
if [ $# -ge 2 ]; then
    exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen sbom --root "$root" --version "$version" --output "$2"
fi
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen sbom --root "$root" --version "$version"
