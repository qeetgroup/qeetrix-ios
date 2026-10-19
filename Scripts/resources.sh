#!/bin/sh
# Resource validation: the built-in strings match the keys the library uses, in every localisation, and
# every snapshot test has exactly its four baselines. (Fonts, icons and generated metadata are held to
# the lock by Scripts/verify.sh.) Offline.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Tools/QeetrixGen" qeetrix-gen resources --root "$root"
