# Release candidate report: 0.1.0-rc.1

2026-10-20. The first release candidate of Qeetrix for iOS, **prepared and not released**. No tag
exists on any repository, nothing was pushed, nothing was published.

- **Candidate:** 0.1.0-rc.1 (`RELEASE_POLICY.md`: the first version, in the 0.x series).
- **Source:** the working tree on `phases-2-to-4` at `10b365f`, with Phases 5–7 uncommitted. A candidate
  must be cut from a committed, reviewed tree; this report is the dry run of that tree.
- **Evidence:** `Scripts/release-check.sh 0.1.0-rc.1 --allow-dirty`, written to
  `.build/release-evidence/0.1.0-rc.1/` (local, not committed). Results below.

## Release-readiness inventory

| Category | What |
|:--|:--|
| **Implemented and verified** (iOS 27.1 simulator, iPhone) | Foundations: tokens, colours, themes, typography and fonts, spacing, sizes, corners, elevation, motion, 37 icons, accessibility helpers. 39 components and patterns: Text, Separator, Card, Badge, Button, Icon button, Spinner, Progress, Avatar, Switch, Text field, Field and field set, Textarea, Password input, One-time code, Checkbox, Radio group, Select, Number field, Form actions and error summary, Tabs, Toast, Sheet (`qeetrixSheet`, `QeetrixSheetContent`), Popover (`qeetrixPopover`), Menu, List item and section header, Description list (the proposal's "key-value row"), Accordion, Empty state, Data state, Skeleton, Chip and chip group, Timeline. Each with unit, snapshot (where Qeetrix draws), UI and accessibility-audit evidence (`Documentation/Quality/COMPONENT_MATURITY_MATRIX.md`) |
| **Implemented, not fully verified** | All of the above on iOS 17, on iPad, on devices, and with VoiceOver, Voice Control, Switch Control and Full Keyboard Access used by a person (`COMPATIBILITY_MATRIX.md`) |
| **Satisfied by native SwiftUI** | Navigation and tab bars (styled with `qeetrixNavigationBar`, `qeetrixTabBar`), alerts and confirmation dialogs (system), menus (system surface), sheets and popovers (system presentation), lists and sections (`List`, `Section`), disclosure (`DisclosureGroup` with `.qeetrix` style), search (`searchable`) |
| **Intentionally deferred** (with the ADR) | A separate centred dialog, snackbar, inline alert (ADR 0014); data table, image presentation (ADR 0015); Feed, TreeView, FilterBar, Pagination, Stat; increased-contrast colours (none upstream); translations of the built-in strings (no source) |
| **Blocked** (outside this repository or this machine) | Tagging and publishing (the owner); a licence for the package's code (the owner); iOS 17 and iPad runs (no runtime or device type here; a download the owner decides); device and assistive-technology checks (a person, a device); CI on GitHub (account billing) |
| **Missing** | Nothing the roadmap required was found missing. A real app consumer is missing: Qeet ID Auth is a React Native app (`CONSUMER_INTEGRATION.md`) |

## Admission gate

| Condition (Phase 7, section 5) | Finding |
|:--|:--|
| Critical security problems | None known (`Documentation/Quality/SECURITY_PRIVACY_REVIEW.md`) |
| Sensitive-data exposure | None known: no logging, storage or description of input |
| Broken critical interactions | None known: every UI test passes |
| Important accessibility defects | None open at P0 or P1. One P3 open (A11Y-4). Device checks not done |
| Package builds | Pass: library, showcase, consumer, Release device build |
| Public API usable | Yes: an independent app built four representative screens with it |
| Token generation consistent | Yes: lock, drift and upstream checks pass; inputs byte-identical to Android's |
| Licensing and redistribution | Third-party: confirmed and now carried in the bundle. Own code: **no licence chosen** — fine for Qeet Group's own use once the owner confirms it; a blocker for anyone else |
| Mandatory checks executed | **Not all:** iOS 17, iPad, devices and CI on GitHub haven't run |
| Crashes or regressions | None known |

## Gate results

`Scripts/release-check.sh 0.1.0-rc.1 --allow-dirty`, 2026-10-20 05:16–06:57 UTC, Xcode 27.1 (Swift 6.4),
macOS 26.6.2, iOS 27.1 iPhone Duo simulator.

| Gate | Result | Evidence |
|:--|:--|:--|
| Version is SemVer and unused | PASS | No local or remote tags exist |
| Clean, committed tree | NOT RUN | A dry run of the uncommitted tree; a real candidate is cut from a commit |
| Host gates (`Scripts/check.sh`) | PASS | 52 generator tests; 225 library tests and 4 timings on the Mac; lock and drift; format; warnings; dependencies, licences and pinned actions; resources; public API |
| Upstream still matches the lock (networked) | PASS | `@qeetrix/ui` 2.1.6 integrity, both fonts' WOFF2, 37 icons |
| Source compatibility with `origin/main` | PASS | "No breaking changes detected" (the icon-name change is allowlisted, ADR 0016) |
| Library tests on iOS | PASS | 225 tests in 56 suites, and 4 timings |
| Snapshot tests, never recorded | PASS | 37 tests, 148 local baselines |
| Showcase builds, warnings as errors | PASS | |
| Showcase UI tests and the accessibility audit | **FAIL → fixed, re-verified** | 93 of 94 passed. `testLightTheme` failed with 41 contrast issues on ordinary text, reproduced on re-run: a defect in the gate itself (TEST-2, below), not in the components. Fixed; see the re-verification below |
| Consumer installs 0.1.0-rc.1 by version | PASS | Resolved alone, by version, from a tagged Git copy; 8 UI tests; Release device build carrying the bundle |
| DocC, warnings as errors | PASS | |
| Privacy: no required-reason API | PASS | No privacy manifest needed |
| Release notes name the version | PASS | |
| Bill of materials | PASS | Regenerated byte-identical to `qeetrix-ios-0.1.0-rc.1.cdx.json` |

Also checked after the run:

- The DocC manifest form, `.package(url:, exact: "0.1.0-rc.1")` with `.product(name: "Qeetrix",
  package: "qeetrix-ios")`, resolves from the tagged copy.
- `.upToNextMinor(from: "0.1.0")` correctly refuses the candidate ("no versions match 0.1.0..<0.2.0").

### TEST-2: the light-theme audit measured a moving layout (P2, fixed)

The gate ran the Dynamic Type check in the same audit call as the contrast check. On a scrolled screen,
the Dynamic Type check re-lays out text as it tries sizes, and contrast was then measured at stale
positions: every heading and button label on 12 pages "failed". Diagnostics showed contrast alone clean
on the same screen, and the combination failing with "Sizes" placed 20 pt from where it was drawn. The
gate now audits Dynamic Type in its own pass, after the others, and waits for the screen to be still
after each swipe (`Documentation/Quality/ACCESSIBILITY_REPORT.md`). The first re-run of the audit class
then reported two remaining issues:

- the inline-code specimen flagged as "not human-readable" — excluded, with the reason;
- an unattributed contrast issue on the 5,000-row list that six settled audits didn't reproduce,
  addressed by the stillness wait.

**Re-verification, 2026-10-20 08:23 UTC.** The whole audit class, after the fix:

| Test | Result |
|:--|:--|
| `testLightTheme` | passed (635 s) |
| `testDarkTheme` | passed (465 s) |
| `testLargestAccessibilitySize` | passed (824 s) |
| `testTextInListsAndGridsScales` | passed (65 s) |

The other 90 showcase UI tests had passed in the dry run, and the gate's file is the only one that
changed since.

### CI-2: test code wasn't held to warnings as errors (P3, fixed)

A strict build of the showcase's UI tests found two Swift 6 data-race warnings in `PopoverUITests`, from
Phase 4: the teardown set the device orientation off the main actor. They went unnoticed because CI and
the release check built only the app with warnings as errors. Fixed, with an async teardown on the main
actor; the three popover tests pass. CI and `release-check.sh` now use `build-for-testing`, which compiles
the UI tests too, and that build reports no warnings. The consumer's builds have none either.

## Decision: **CONDITIONAL GO** — an internal evaluation candidate

**0.1.0-rc.1 may be tagged, once the conditions below are met, as a release candidate for Qeet Group's own iOS teams to evaluate and integrate:**

- pinned exactly (`exact: "0.1.0-rc.1"`);
- on iPhone;
- not for an App Store release of a production app.

This is not approval of 0.1.0, and nothing has been tagged.

**Why not GO:**

- **Mandatory checks that haven't run:**
  - iOS 17, the minimum supported version;
  - any iPad;
  - a physical device, and assistive technology used by a person;
  - CI on GitHub, where every job is blocked by account billing.
- **No real app has integrated.** The intended first consumer, Qeet ID Auth, is a React Native app.
- **The package's own licence is undecided.**

**Why not NO-GO:**

- No P0 or P1 defect is known.
- Every gate that can run here passes, after the defects the dry run found were fixed and re-verified.
- An independent app installs the candidate by version and works, on iPhone, with its resources.
- Third-party licences are confirmed, and their notices ship in the bundle.
- Privacy is evaluated: no manifest is needed.
- The documentation is ready.
- No step can publish without the owner.

The remaining risks are documented, and an evaluation-only, exactly-pinned candidate is compatible with
them.

**Conditions before the owner tags 0.1.0-rc.1:**

1. **Commit and review.** Commit Phases 5–7 through a reviewed pull request, then run
   `Scripts/release-check.sh 0.1.0-rc.1` on that commit. It must have no FAIL, and the only NOT RUN may be
   the gates listed above.
2. **Confirm the licence.** The owner confirms in writing that Qeetrix for iOS is proprietary, for Qeet
   Group's internal use (`LICENSE_COMPLIANCE.md`, decision 1).
3. **Tag.** The owner approves and creates the tag (`RELEASE_CHECKLIST.md`, steps 4–6).

**To reach GO for 0.1.0, the first non-candidate release:**

1. Pass the library, snapshot, showcase and audit suites on an iOS 17 simulator and on an iPad simulator.
   This needs the iOS 17 runtime download (`COMPATIBILITY_MATRIX.md`).
2. Complete the device accessibility checklist: VoiceOver, Voice Control, Switch Control, Full Keyboard
   Access, the largest text size and Bold Text, on an iPhone and an iPad.
3. Get one green run of the CI workflow on GitHub, which needs Actions billing unblocked.
4. Either have one native SwiftUI app integrate the candidate, or have the owner accept shipping 0.1.0
   before any real app uses it.
5. Release no candidate with an open P0, P1 or P2 defect. LOC-1 (English-only strings) is P2: translate
   the strings, or accept it in writing for 0.1.0.
