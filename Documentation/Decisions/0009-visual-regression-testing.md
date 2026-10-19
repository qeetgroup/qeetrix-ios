# 0009 — Visual regression testing for components

**Status:** Accepted (Phase 2, 2026-10-18), amended by [ADR 0013](0013-snapshot-baselines-stay-local.md):
baselines are recorded locally and never committed, so CI does not compare snapshots. Proposed in
Phase 1; adopted with the first components, with the two changes noted under *Decision*.

## Context

Components can regress visually without failing a behaviour test, for example through a token change,
a layout change, or a new Dynamic Type size. Skyscanner Backpack and Adevinta Spark use Point-Free's
SnapshotTesting for this. Phase 1 checked rendering with targeted pixel assertions (`Rendered` in the
tests), which stay for exact token checks.

## Decision

- **Target.** `Tests/QeetrixSnapshotTests` in the root package, using Point-Free's
  `swift-snapshot-testing`, pinned **exactly** to 1.19.6 so a baseline never changes under a dependency
  bump. It is a test-only dependency: no library target uses it. `Package.resolved` is committed.
- **Checked before adding it** (2026-10-18):
  - *Licences.* swift-snapshot-testing 1.19.6, swift-custom-dump 1.7.3 and swift-issue-reporting 2.1.2
    are MIT; swift-syntax 604.0.0 (a macro dependency of the Point-Free packages) is Apache 2.0 with the
    Runtime Library Exception. None of them ships in an app.
  - *Compatibility.* 1.19.6 declares tools 6.0 and supports Swift Testing; it builds and runs here under
    Xcode 27.1 and Swift 6.4.
  - *What an app resolves, measured.* A Swift package depending on `Qeetrix`, and the Xcode showcase
    app, each resolved only `qeetrix-ios`: no checkouts, repositories or artifacts were fetched.
    SwiftPM does not resolve another package's test-only dependencies. Both were measured with a local
    path dependency; a URL dependency resolves the same way but has not been measured, because nothing
    is published.
  - *What a contributor resolves.* Developing this package fetches the four packages above, and the
    swift-syntax prebuilt where Xcode offers one.
- **The baseline matrix.** Every component has one *specimen* per test — its variants and states
  (disabled, error, loading, selected) side by side — recorded in four configurations:

  | Configuration | Theme | Text size | Direction |
  |:--|:--|:--|:--|
  | `light` | light | Large (default) | left-to-right |
  | `dark` | dark | Large | left-to-right |
  | `ax3` | light | accessibility 3 | left-to-right |
  | `rtl` | light | Large | right-to-left |

  That is 4 images per specimen: the matrix is representative, not a cross-product.
- **Recording conditions**, set by `Tests/QeetrixSnapshotTests/Support/SnapshotMatrix.swift`: the iOS
  27 simulator (the test fails with that reason on another major version), the `en_US` locale, a 390 pt
  width, the compact size class, animations off, scale 2. Theme, text size and direction are set in
  both the environment and the trait collection, so measurement and drawing agree.
- **Tolerance.** 99.5% of pixels must match, each to a perceptual precision of 98%, to absorb
  anti-aliasing differences between machines without hiding a colour or layout change.
- **Where baselines live.** `Tests/QeetrixSnapshotTests/__Snapshots__/<Family>/<TestFile>/`, one folder
  the manifest excludes once.
- **Recording.** `SNAPSHOT_TESTING_RECORD=all` (for xcodebuild, `TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all`)
  re-records. CI runs with `never`, so a missing baseline fails instead of being recorded.

**Changed from the proposal.**

- *Scale 2, not 3.* Hairlines are still 2 pixels, and the baselines are under half the size.
- *States in every configuration.* A disabled or error state can fail in dark or at AX3 as easily as in
  the default configuration, and putting them in the specimen costs no extra images.

## Consequences

- The package has its first dependency, test-only.
- Reference images are reviewed artifacts in pull requests. Re-recording them needs a reason in the
  pull request.
- Snapshots run on the iOS simulator only (`#if os(iOS)`); on the Mac host the target builds and runs no
  tests.
- Snapshots complement behaviour, accessibility and UI tests; they do not replace them.
