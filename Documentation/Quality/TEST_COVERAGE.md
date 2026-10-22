# Test coverage

Phase 6, 2026-10-20. What is tested, where, and what isn't. The per-component view is in
`COMPONENT_MATURITY_MATRIX.md`.

## Suites

| Suite | Framework | Runs on | Tests | Last result (Phase 6) |
|:--|:--|:--|:--|:--|
| `QeetrixTests` | Swift Testing, plus XCTest for timings | Mac host and iOS simulator | 223 tests in 56 suites, plus 4 timing tests | All pass on both |
| `QeetrixSnapshotTests` | Swift Testing with swift-snapshot-testing | iOS simulator | 37 tests; 148 baseline images (light, dark, accessibility size, right to left) | All pass, after 7 accessibility-size specimens were re-recorded on purpose (below) |
| `QeetrixShowcaseUITests` | XCTest UI tests | iOS simulator | 94 tests, including the accessibility audit gate | 93 passed in the full run (63.5 minutes); the 94th, new, failed on its own query and passed when re-run after the fix (below) |
| `QeetrixGenCoreTests` | Swift Testing | Mac host | 49 tests | All pass |

Line coverage is not measured: the tests are written against behaviour, tokens and rendered output, not
against a coverage target.

## What each layer checks

- **Unit tests** check behaviour against something independent of the code: the upstream snapshot,
  the agreed brand values, upstream's WCAG pairs and rendered pixels. Integration tests compile every
  DocC example against the public API only.
- **Snapshot tests** compare one specimen of every component Qeetrix draws in four configurations. The
  baselines live only on the machine that records them (ADR 0013), so CI doesn't run them.
- **UI tests** drive the showcase: taps, typing, focus, presentation, VoiceOver labels, values and
  traits, touch-target sizes, reflow at accessibility sizes, and Apple's accessibility audit.

## Added in Phase 6

| Test | Covers |
|:--|:--|
| `AccessibilityAuditUITests` (4 tests) | Apple's audit on every showcase page in light, dark and the largest size; text in lists and grids measured scaling |
| `PasswordInputUITests.testATapOnTheFieldsPaddingFocusesIt` | A11Y-1 |
| `TextareaUITests.testATapInTheBoxBelowTheTextFocusesIt` | The textarea's box is its target |
| `LargeTextTests` (4 tests) | A11Y-5, A11Y-6: icon squares, icon buttons busy or not, the checkbox mark, the select wrapping |
| `TimelineTests` right-to-left connector | LOC-3 |
| `TimelineContrastTests` | The timeline dots' 3:1 contrast |
| `TypeCacheTests` (3 tests), `RenderingPerformanceTests` (4 timings) | PERF-1 and the performance figures |
| `ScriptFallbackTests` (2 tests) | Non-Latin scripts fall back through CoreText |
| `IconNameContractTests` | API-1: the icon-name struct keeps the enum's behaviour |
| `Scripts/dependencies.sh`, `Scripts/api-compat.sh` | SEC-1, CI-1 |

Two tests were run with their fix reverted, and failed: the right-to-left connector (Mac host) and the
icon button (iOS). The others assert exactly what the defect broke — a field element at least 36 pt
tall where it measured 19–20 pt, a value on more than one line, the same pixels at two text sizes —
so they can't pass with the defect in place.

`waitForKeyboardFocus()` replaced an assertion that read focus at once (TEST-1).

## Runs behind these results

All on Xcode 27.1 (Swift 6.4), the Mac host (macOS 26.6, Apple silicon) and the iOS 27.1 iPhone Duo
simulator, the only device that runtime offers here.

| Command | Result |
|:--|:--|
| `Scripts/check.sh` | All host gates pass: 49 generator tests; 223 library tests and 4 timings on the host; drift, format, warnings, dependencies and pins, resources, public API |
| `xcodebuild test -scheme Qeetrix -only-testing:QeetrixTests` (iOS) | 223 tests and 4 timings; one failure in the first run — a busy icon button narrower than an idle one at the largest size — fixed; then the whole suite re-run: 223 and 4 pass |
| `TEST_RUNNER_SNAPSHOT_TESTING_RECORD=never xcodebuild test -scheme Qeetrix -only-testing:QeetrixSnapshotTests` | 7 of 37 failed, every one an accessibility-size specimen of a component A11Y-6 changed (button, icon button, menu trigger, password, number field, checkbox, avatar). Each new image was compared with its reference; the 7 were re-recorded with `RECORD=failed` on those suites only, and the full comparison then passed 37 of 37. No default-size, dark or right-to-left specimen changed. |
| Full showcase UI suite | 94 tests: 93 passed; `testTextInListsAndGridsScales` failed on an ambiguous query, then on a threshold set too tight for a footer's padding; both fixed in the test, and it passed |

A busy simulator once left a field's focus to land after the assertion, and an `xcodebuild` started
alongside a DocC build couldn't find the simulator; both are recorded here rather than retried away.

## Phase 7 additions

| Suite or check | Tests | Result (2026-10-20) |
|:--|:--|:--|
| `QeetrixTests` | 225 (two added: the bundled icon licence; the *Migrating* example) | All pass, Mac host and iOS |
| `QeetrixGenCoreTests` | 52 (three added: the bill of materials) | All pass |
| `QeetrixConsumerUITests` (new app) | 8 | All pass, by path and installed by version |
| `AccessibilityAuditUITests` | 4 | All pass after TEST-2, with Dynamic Type in its own pass |

## Gaps

| Gap | Why | Covered instead by |
|:--|:--|:--|
| No dedicated UI test for text, separator and badge | They have no behaviour beyond their drawing and semantics | Unit and snapshot tests, and the audit gate on their pages |
| Snapshot tests don't run in CI | Baselines aren't committed (ADR 0013) | Rendered-pixel unit tests, which run in CI |
| The snapshot host draws accessibility sizes after measuring at the default size | A limit of the host (ADR 0015) | UI tests and the audit at accessibility sizes in the running app |
| Dynamic Type on the Mac host | macOS has no Dynamic Type | The same tests on the iOS simulator, which first check that icons scale |
| VoiceOver speech, Full Keyboard Access, Switch Control | A UI test can't hear speech or move VoiceOver's focus | Labels, values and traits in UI tests; device checks are GAP-1 |
| iPad, iOS 17 | No simulator can be created here | GAP-2, GAP-3 |
