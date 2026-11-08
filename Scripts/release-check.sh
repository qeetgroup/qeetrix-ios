#!/bin/sh
# Release-candidate verification: runs every release gate against the working tree and writes the
# evidence — logs, the SBOM and a summary — to .build/release-evidence/<version>/. It publishes nothing: no tag,
# no push, no release. Those are the owner's steps in docs/releases.md
#
#   Scripts/release-check.sh <version> [--allow-dirty]
#
# A gate is PASS only if it ran and succeeded; one that can't run here is NOT RUN, never PASS. The run
# continues past a failure so the evidence is complete, and exits non-zero if any gate failed. NOT RUN
# gates don't fail the run — on CI the local snapshot baselines never exist — but the summary lists them,
# and the release checklist requires the owner to account for each before approving.
# A candidate is cut from a clean, committed tree; --allow-dirty records a dry run of an uncommitted tree.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
version=${1:?usage: Scripts/release-check.sh <version> [--allow-dirty]}
allow_dirty=no
[ "${2:-}" = "--allow-dirty" ] && allow_dirty=yes
evidence="$root/.build/release-evidence/$version"
rm -rf "$evidence"
mkdir -p "$evidence"
summary="$evidence/SUMMARY.md"
failed=0
not_run=0

record() {  # record <PASS|FAIL|NOT RUN> <gate> <detail>
    printf '| %s | %s | %s |\n' "$2" "$1" "$3" >>"$summary"
    printf '%-8s %s — %s\n' "$1" "$2" "$3"
    case "$1" in FAIL) failed=$((failed + 1)) ;; "NOT RUN") not_run=$((not_run + 1)) ;; esac
}
gate() {  # gate <name> <log> <command...>
    name=$1
    file="$2.log"
    shift 2
    if "$@" >"$evidence/$file" 2>&1; then record PASS "$name" "$file"; else record FAIL "$name" "$file (exit $?)"; fi
}

{
    echo "# Release-candidate evidence: $version"
    echo
    echo "- Revision: $(git rev-parse HEAD) ($(git rev-parse --abbrev-ref HEAD))"
    echo "- Working tree: $(git status --porcelain | wc -l | tr -d ' ') changed or untracked paths"
    echo "- Run: $(date -u '+%Y-%m-%dT%H:%M:%SZ') on macOS $(sw_vers -productVersion), $(xcodebuild -version | head -n 1), $(swift --version 2>/dev/null | head -n 1)"
    echo
    echo "| Gate | Result | Evidence |"
    echo "|:--|:--|:--|"
} >"$summary"

# 1. Source revision and version.
if echo "$version" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(rc|beta|alpha)\.[1-9][0-9]*)?$'; then
    record PASS "Version is SemVer" "$version"
else
    record FAIL "Version is SemVer" "$version is not MAJOR.MINOR.PATCH[-rc.N]"
fi
if git rev-parse -q --verify "refs/tags/$version" >/dev/null; then
    record FAIL "Version is unused" "tag $version already exists"
else
    record PASS "Version is unused" "no local tag $version"
fi
if [ -z "$(git status --porcelain)" ]; then
    record PASS "Clean, committed tree" "$(git rev-parse --short HEAD)"
elif [ "$allow_dirty" = yes ]; then
    record "NOT RUN" "Clean, committed tree" "dry run of an uncommitted tree (--allow-dirty): not releasable as is"
else
    record FAIL "Clean, committed tree" "uncommitted changes; commit them, or pass --allow-dirty for a dry run"
fi

# 2. Host gates: generator, lock and drift, format, warnings, dependencies and pinned actions, resources,
#    host tests.
gate "Host gates (Scripts/check.sh)" check Scripts/check.sh
gate "Upstream still matches the lock (networked)" upstream Scripts/sync-upstream.sh --check

# 3. Source compatibility with the last release tag, or main before the first.
baseline=$(git describe --tags --abbrev=0 2>/dev/null || echo origin/main)
gate "Source compatibility with $baseline" api-compat Scripts/api-compat.sh "$baseline"

# 4. iOS.
sim=$(Scripts/ci-simulator.sh 2>/dev/null)
if [ -z "$sim" ]; then
    record "NOT RUN" "iOS gates" "no iOS simulator available"
else
    gate "Library tests on iOS" ios-tests xcodebuild test -scheme Qeetrix-Package -only-testing:QeetrixTests \
        -destination "platform=iOS Simulator,id=$sim" -derivedDataPath .build/xcode
    if [ -n "$(find Tests/QeetrixSnapshotTests/__Snapshots__ -name '*.png' 2>/dev/null | head -n 1)" ]; then
        gate "Snapshot tests against local baselines (never recorded)" snapshots env TEST_RUNNER_SNAPSHOT_TESTING_RECORD=never \
            xcodebuild test -scheme Qeetrix-Package -only-testing:QeetrixSnapshotTests \
            -destination "platform=iOS Simulator,id=$sim" -derivedDataPath .build/xcode
    else
        record "NOT RUN" "Snapshot tests" "no local baselines (ADR 0013): record them on the previous release first"
    fi
    gate "Showcase and its UI tests build, warnings as errors" showcase-build xcodebuild build-for-testing \
        -project Showcase/QeetrixShowcase.xcodeproj -scheme QeetrixShowcase \
        -destination "platform=iOS Simulator,id=$sim" -derivedDataPath .build/showcase SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
    gate "Showcase UI tests and the accessibility audit" showcase-ui xcodebuild test \
        -project Showcase/QeetrixShowcase.xcodeproj -scheme QeetrixShowcase \
        -destination "platform=iOS Simulator,id=$sim" -derivedDataPath .build/showcase -collect-test-diagnostics never
fi
gate "DocC builds, warnings as errors" docs Scripts/docs.sh

# 5. Privacy: a manifest is needed once the library uses a required-reason API (Apple's list).
required_reason='creationDate|modificationDate|systemUptime|mach_absolute_time|volumeAvailableCapacity|activeInputModes|UserDefaults|AppStorage'
hits=$(find Sources/Qeetrix -name '*.swift' -exec grep -nE "$required_reason" {} + | grep -vE ':[0-9]+:[[:space:]]*///' || true)
if [ -z "$hits" ]; then
    record PASS "Privacy: no required-reason API" "no PrivacyInfo.xcprivacy needed"
elif [ -f Sources/Qeetrix/PrivacyInfo.xcprivacy ]; then
    record PASS "Privacy: manifest present for required-reason APIs" "review it against: $hits"
else
    echo "$hits" >"$evidence/privacy.log"
    record FAIL "Privacy: required-reason API without a manifest" "privacy.log"
fi

# 6. Release documents and the bill of materials.
if grep -q -F "## [$version]" CHANGELOG.md 2>/dev/null; then
    record PASS "The CHANGELOG has an entry for $version" "CHANGELOG.md"
else
    record FAIL "The CHANGELOG has an entry for $version" "CHANGELOG.md: add ## [$version] — YYYY-MM-DD"
fi
gate "Bill of materials (CycloneDX)" sbom Scripts/sbom.sh "$version" "$evidence/qeetrix-ios-$version.cdx.json"

{
    echo
    echo "Failed: $failed. Not run: $not_run."
    echo
    echo "Not checkable here, and so never PASS in this summary: an iOS 17 runtime, an iPad, physical devices,"
    echo "VoiceOver and other assistive technology by a person, and the CI workflow on GitHub."
} >>"$summary"
printf '\nEvidence: %s\nFailed: %d. Not run: %d.\n' "$evidence" "$failed" "$not_run"
[ "$failed" -eq 0 ]
