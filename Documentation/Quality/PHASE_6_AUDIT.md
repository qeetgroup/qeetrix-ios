# Phase 6 audit: quality, accessibility and performance hardening

2026-10-19 to 2026-10-20. An audit of everything Phases 1–5 built, on the working tree that follows
`10b365f` (the tree merged to `main` as `ed46253`), with Xcode 27.1 (Swift 6.4), the Mac host and the
iOS 27.1 iPhone simulator. Phase 6 added no components.

Each finding was fixed with a regression test, accepted with a reason, or recorded as a release gap.
Nothing was found at P0.

## Reports

| Area | Report |
|:--|:--|
| Component maturity | [COMPONENT_MATURITY_MATRIX.md](COMPONENT_MATURITY_MATRIX.md) |
| Accessibility | [ACCESSIBILITY_REPORT.md](ACCESSIBILITY_REPORT.md) |
| Localization and right-to-left | [LOCALIZATION_REPORT.md](LOCALIZATION_REPORT.md) |
| Performance | [PERFORMANCE_REPORT.md](PERFORMANCE_REPORT.md) |
| Security and privacy | [SECURITY_PRIVACY_REVIEW.md](SECURITY_PRIVACY_REVIEW.md) |
| Public API compatibility | [API_COMPATIBILITY.md](API_COMPATIBILITY.md) |
| Tests | [TEST_COVERAGE.md](TEST_COVERAGE.md) |
| What remains before a release | [RELEASE_READINESS_GAPS.md](RELEASE_READINESS_GAPS.md) |

## Findings

Severity: **P0** stops any release; **P1** must be closed or explicitly accepted before apps depend on
the package; **P2** should be closed before a release; **P3** can follow.

| ID | Sev. | Area | Finding | Status | Regression test |
|:--|:--|:--|:--|:--|:--|
| A11Y-1 | P1 | Accessibility | Password field: a 19–20 pt element, and a tap on its padding didn't focus it | Fixed | `PasswordInputUITests.testATapOnTheFieldsPaddingFocusesIt` |
| A11Y-5 | P2 | Accessibility | The select cut its value to one line at the accessibility sizes ("Choose a co…") | Fixed: it wraps there | `LargeTextTests`; the audit gate at the largest size |
| A11Y-6 | P2 | Accessibility | Icons spilled out of fixed squares at the accessibility sizes: icon buttons and icon-only menus, the password eye, the number-field steppers; the checkbox mark and avatar icon would outgrow their boxes | Fixed: squares grow with their icon (`qeetrixIconSquare`); fixed marks in fixed boxes; the busy indicator scales | `LargeTextTests` |
| API-1 | P2 | API stability | `QeetrixIconName` was an enum, so every new icon broke apps that switch over icons; the checker reported eight breaks for Phase 5's icons | Fixed: a struct (ADR 0016); the one break is allowlisted and documented with its migration | `IconNameContractTests`; `Scripts/api-compat.sh` |
| PERF-1 | P2 | Performance | Every Qeetrix text rebuilt its variable font on every view update | Fixed: a bounded, locked cache | `TypeCacheTests` (same result, bold in the key, bounded); `RenderingPerformanceTests` |
| LOC-3 | P2 | Right-to-left | The timeline's connector stayed on the left while its markers moved right | Fixed | `TimelineTests` "Right to left, the connector follows the markers to the right edge" |
| LOC-1 | P2 | Localization | The library's 19 strings are English only | Open: needs a translation source and a decision | — (`RELEASE_READINESS_GAPS.md`) |
| CI-1 | P3 | CI | Nothing checked source compatibility between revisions: the symbol-list check can't see a changed type or a new enum case | Fixed: `Scripts/api-compat.sh`, run on pull requests | The CI step itself |
| SEC-1 | P3 | Supply chain | The workflow used `actions/checkout@v4`, a movable tag | Fixed: pinned by commit | `Scripts/dependencies.sh` fails on an unpinned action |
| DESIGN-1 | P3 | Tokens | `max-w-sm` (384 pt) was a literal in two components | Fixed: `QeetrixWebScale.containerSM` | Existing toast and empty-state metric tests |
| A11Y-2 | P3 | Showcase | The app-navigation link was 17 pt tall | Fixed | The audit gate |
| A11Y-3 | P3 | Showcase | "Native button" repeated its trait | Fixed | The audit gate |
| TEST-1 | P3 | Tests | The password focus test checked focus at once; focus from a tap gesture lands later | Fixed: `waitForKeyboardFocus()` | Used by both tap-to-focus tests |
| A11Y-4 | P3 | Accessibility | The small spinner's VoiceOver frame turns with it | Open | — (`RELEASE_READINESS_GAPS.md`) |
| LOC-2 | P3 | Localization | Two accessibility labels join parts with a Latin comma | Accepted: VoiceOver pauses at it in every language | — |

## By area

### Accessibility

A survey of Apple's accessibility audit over every showcase page found 413 raw issues; three were
defects (A11Y-1 to A11Y-3). The rest were the audit misreading disabled controls, elements under bars,
the system search field, avatar initials, drawn glyphs, text in lazy containers, and its prediction of
clipping. The audit is now a gate over every page in light, dark and the largest accessibility size,
with each exclusion documented. Its first run flagged one more defect at the largest size (A11Y-5),
and the screenshots taken to check its flags showed another (A11Y-6); both are fixed.

### Localization and right-to-left

Right-to-left layout and doubled-length strings were checked on twelve pages, and non-Latin scripts
through a CoreText fallback test. One defect (LOC-3) was fixed. The library's strings have no
translations (LOC-1).

### Performance

Measured, not assumed: resolving 2,000 typefaces took 0.094 s uncached and 0.001 s cached on the
simulator (about 95 times faster), and 0.091 s and 0.0013 s on the Mac host. The report has the
rendering, icon and scrolling figures.

### Reliability and concurrency

- Swift 6 language mode with strict concurrency; the warnings gate fails on any warning.
- Shared state: two caches change after launch, both bounded — rendered icon images (main actor) and
  resolved typefaces (an `OSAllocatedUnfairLock`).
- Lifecycles: the toast's timer is a `.task(id:)`, cancelled with its view; repeating animations
  (spinner, progress sweep, skeleton) belong to their view's state and end with it; the spinner and
  the skeleton follow Reduce Motion while visible.
- Crash paths: the library has no `try!`, `fatalError` or `as!`. Two force unwraps remain, each behind
  an invariant: every icon has a round outline drawing (the generator refuses one without), and a
  fixed 1 × 1 bitmap context can't fail.

No defects found.

### Security and privacy

No network, storage, pasteboard, tracking or required-reason APIs; no privacy manifest needed; logging
carries no user data; sensitive fields use the system's secure entry. One supply-chain fix (SEC-1).

### API stability

`api-check` (the symbol list) and the new `api-compat` (Swift's source-compatibility checker) both
pass. One deliberate break, the icon-name struct, with ADR 0016 and a migration note.

### Tests

Unit, snapshot and UI tests cover every component; the audit gate covers the pages of the three
components without a dedicated UI test (text, separator, badge). Counts and gaps are in
`TEST_COVERAGE.md`.

### Design tokens

Numeric literals in component code were searched for. Apart from defaults (six code digits, six
loading rows), the button's busy indicator, drawn from the web's 16-unit SVG geometry, and the
read-only field's 3 pt dash, which stands in for the browser's dashed border, every size comes from a
token or a named web metric. One literal (384 pt, twice) became a named metric (DESIGN-1). A minor
timeline dot is under 3:1 by upstream design and is recorded for review.

### Documentation and showcase

The README, ARCHITECTURE, CONTRIBUTING, PHASES, CHANGELOG, the accessibility standard, the component
contract, the cross-platform contract and the Icons DocC page were updated for this phase. The showcase
had two accessibility fixes (A11Y-2, A11Y-3).

### CI

Added the source-compatibility step for pull requests, commit-pinned actions and their check, and the
audit gate within the UI tests; the showcase job's timeout went from 45 to 100 minutes, as the suite
now takes 64 minutes locally. The workflow has never started on GitHub: every job is blocked by the
account's billing (GAP-4).

## Not verified

Device checks, an iPad, an iOS 17 runtime, performance on a device and CI on GitHub. The reasons and
what closes each are in `RELEASE_READINESS_GAPS.md`.
