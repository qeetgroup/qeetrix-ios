#!/bin/sh
# Fail if the upstream snapshot differs from its lock, or if any generated file is not exactly what
# the snapshot generates (edited by hand, stale, or left over). Offline.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
exec swift run --quiet --package-path "$root/Scripts" qeetrix-gen verify --root "$root"
