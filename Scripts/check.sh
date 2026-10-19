#!/bin/sh
# Every gate that runs on the Mac without a simulator, in the order CI runs them. Stops at the first
# failure. The iOS gates — library, snapshot and UI tests on the Simulator, and the DocC build — are in
# README.md#build-and-test and .github/workflows/ci.yml.
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
step "Public API";                 Scripts/api-check.sh
printf '\n✓ All host gates passed.\n'
