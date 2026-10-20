# Release-readiness gaps

Phase 6, 2026-10-19. What still stands between the package and a first release, after the Phase 6
audit and fixes. Severity: **P0** stops any release; **P1** must be closed or explicitly accepted before
a release apps depend on; **P2** should be closed before a release; **P3** can follow.

None is P0: nothing found is known to break an app, lose data or expose what a person typed.

**Phase 7 update (2026-10-20).**

- GAP-10 is closed: distribution, versioning and the release process are decided (ADR 0017,
  `Documentation/Releases/`).
- GAP-9 now covers Phases 5–7.
- GAP-8 is recorded as a release blocker for distribution outside Qeet Group
  (`Documentation/Releases/LICENSE_COMPLIANCE.md`).
- The current list of what blocks a release is in `Documentation/Releases/RELEASE_CANDIDATE_REPORT.md`.

## Verification gaps

| ID | Gap | Severity | What closes it | Who |
|:--|:--|:--|:--|:--|
| GAP-1 | **No device checks.** VoiceOver speech and order, Full Keyboard Access, Switch Control, the largest text size on real screens, Bold Text, Increased Contrast, Smart Invert and Differentiate Without Colour have been checked only through automated tests and the simulator. The list per component is in `Documentation/Standards/ACCESSIBILITY.md`. | P1 | A person runs the checklist on an iPhone and an iPad, and records the results in `ACCESSIBILITY_REPORT.md` | Needs a person and devices |
| GAP-2 | **iOS 17 never run.** The deployment target is iOS 17; everything compiles against it, but only the iOS 27.1 runtime is installed, and `simctl create` fails for any other device here. | P1 | Install an iOS 17 simulator runtime (`xcodebuild -downloadPlatform iOS -buildVersion 17.5`) and run the library and UI tests on it | Needs the download, which needs your approval |
| GAP-3 | **No iPad run.** No iPad simulator can be created here; regular width was checked only through an iPhone in landscape. Sheets, popovers, `Table` and the description list's columns behave differently on iPad. | P1 | Run the UI tests and the audit gate on an iPad simulator, then on a device | As GAP-2 |
| GAP-4 | **CI has never run on GitHub.** The workflow passes `actionlint` and every step has been run locally. On GitHub every job of every run so far — including pull request #1 — was "not started because recent account payments have failed or your spending limit needs to be increased". Whether the `macos-26` image carries Xcode 27.1 is also unconfirmed. | P1 | Unblock Actions; run the workflow once on the pushed branch | Account owner |
| GAP-5 | **Performance on a device.** Every figure in `PERFORMANCE_REPORT.md` is from the Mac host or the simulator, which are not a phone's CPU, GPU or memory. | P2 | Run `RenderingPerformanceTests` and the 5,000-row UI test on the oldest supported iPhone | Needs a device |

## Product gaps

| ID | Gap | Severity | What closes it |
|:--|:--|:--|:--|
| LOC-1 | **The library's 19 strings are English only** (`LOCALIZATION_REPORT.md`). An app localised into Hindi or Arabic still says "Loading", "Required" and "Close" in English. | P2 | A decision: ship reviewed translations for the languages Qeet products support, or let apps supply their own table |
| GAP-6 | **No increased-contrast colours.** Qeetrix reads Increased Contrast but has no values to switch to, because `@qeetrix/ui` defines none. | P2 | Upstream defines a high-contrast theme; the generator already fails on unknown themes, so it will be picked up deliberately |
| GAP-7 | **Design review items** recorded since Phase 1: web body text is 14 pt where iOS body is 17 pt; Bold Text moves one weight step; a minor timeline event's dot is under 3:1 by upstream design. | P3 | A design review with the web team |
| A11Y-4 | **The spinner's VoiceOver frame turns with it** (`ACCESSIBILITY_REPORT.md`). | P3 | Keep the accessibility element on a frame that doesn't rotate, with a UI test of its frame |

## Release mechanics (Phase 7's)

| ID | Gap | Severity | What closes it |
|:--|:--|:--|:--|
| GAP-8 | **No licence for the package's own code.** `@qeetrix/ui` is published `UNLICENSED`; Qeetrix iOS follows it and chooses none. Bundled fonts and icons carry their own licences. | P1 for any distribution outside Qeet Group | Qeet Group chooses a licence |
| GAP-9 | **Uncommitted work.** `origin/main` has Phases 1–4 (`ed46253`, pull request #1, merged 2026-10-19 without a CI run). Phases 5, 6 and 7 are uncommitted in the working tree, on top of `10b365f`. | P1 | Commit, push and review through a pull request, with your go-ahead |
| GAP-10 | **No version, tag or release; no distribution decided.** Closed in Phase 7: source package, SemVer from 0.1.0, candidate 0.1.0-rc.1 prepared (ADR 0017). Tagging remains the owner's | — | Owner approves and tags (`Documentation/Releases/RELEASE_CHECKLIST.md`) |
| GAP-11 | **Snapshot baselines are local** (ADR 0013), so CI can't compare rendering. Rendering is still checked in CI through rendered-pixel unit tests and the UI tests. | P3 | Accepted by ADR 0013; revisit if a shared baseline store is wanted |
| GAP-12 | **The UI suite's CI time.** With the accessibility audit gate the showcase job runs longer; its timeout was raised to match the local run (see `TEST_COVERAGE.md`). GitHub's runners may be slower. | P3 | Watch the first runs; split the audit into its own job if needed |

## Closed in Phase 6

A11Y-1, A11Y-2, A11Y-3, A11Y-5, A11Y-6, PERF-1, API-1, LOC-3, SEC-1, DESIGN-1, CI-1 and TEST-1 — see
`PHASE_6_AUDIT.md`.
