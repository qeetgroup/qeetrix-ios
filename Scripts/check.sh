#!/bin/sh
# Every gate that runs on the Mac without a simulator. Stops at the first failure. CI's Verify runs four of them
# (upstream lock, formatting, warnings, dependencies); the rest, and the iOS gates (the library's tests on the
# Simulator, DocC, source compatibility), are the local gate in CONTRIBUTING.md, "Before you push".
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
step() { printf '\n▸ %s\n' "$1"; }
step "Generator tests";            swift test --package-path Tools/QeetrixGen
step "Upstream lock and drift";    Scripts/verify.sh
step "Formatting";                 Scripts/lint.sh
step "Compiler warnings";          Scripts/warnings.sh
step "Dependencies and licences";  Scripts/dependencies.sh
step "Resources";                  Scripts/resources.sh
step "Library tests (Mac host)";   swift test
step "Extended icons' size";       Scripts/icon-budget.sh
printf '\n✓ All host gates passed.\n'
