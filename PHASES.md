# Phases

Qeetrix for iOS is built in phases. Each one ends with its own verification. Later phases are planning
boundaries, not commitments of scope.

| Phase | Scope | Status |
|:--|:--|:--|
| 1 — Foundations | Token pipeline from `@qeetrix/ui`; semantic colours; light/dark/system theming; typography with the bundled fonts and Dynamic Type; spacing, size, corners, stroke, focus, density, elevation, motion; icon infrastructure with a representative set; accessibility helpers; showcase app; tests, CI, docs | Done |
| 2 — Core components | Text, Separator, Card, Badge, Button, Icon button, Spinner, Progress, Avatar, Switch, Text field, with their `component.*` tokens; the component template and scaffold; snapshot and UI tests; CI gates | Done |
| 3 — Inputs and forms | Field and field set, textarea, password, one-time code, checkbox, radio group, select, number field; form actions and error summary | Done |
| 4 — Navigation, overlays, feedback | Tabs; navigation and tab bar styling; alert and confirmation dialogs; sheets; popovers; menus; toasts | Done |
| 5 — Data display, collections, content states | List rows and section headers; description list; accordion; empty, data and skeleton states; chips; timeline; native search integration | Done |
| 6 — Quality, accessibility and performance hardening | Audit of Phases 1–5: accessibility audit gate, localization and right-to-left, measured performance, security and privacy, source compatibility, maturity matrix and release-readiness gaps | Done |
| **7 — Production readiness and release** | Consumer integration, distribution, versioning and release policy, licensing and SBOM, release verification and workflow, DocC installation guides, the 0.1.0-rc.1 candidate and its go/no-go | **Current: candidate prepared, not released** |

## Phase 7 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 iPhone simulator:

- **Consumer integration.** An independent app, `Examples/QeetrixConsumer`, installs the package by
  version from a tagged throwaway repository, passes its UI tests (including Apple's accessibility
  audit), and builds for devices in Release with Qeetrix's resources.
- **Release engineering.**
  - `Scripts/release-check.sh` and the hand-run "Release candidate verification" workflow; neither
    publishes anything.
  - The consumer check in CI.
  - A CycloneDX bill of materials.
- **Policies.** Distribution (ADR 0017), release, support, checklist and rollback in
  `Documentation/Releases/`, and `.github/SECURITY.md`.
- **Licensing.** The icon artwork's notice now ships in the resource bundle; licences reviewed.
- **Documentation.** DocC *Installing and updating*, *Migrating* and *Troubleshooting*; release notes;
  the ui.qeet.in handoff.
- **The candidate:** 0.1.0-rc.1, with its report and decision in
  `Documentation/Releases/RELEASE_CANDIDATE_REPORT.md`.

Not done, and not to be done without the owner:

- tagging, pushing or publishing anything;
- choosing a licence;
- installing an iOS 17 runtime.

Still to verify: iOS 17, iPad, devices and assistive technology by a person, CI on GitHub (blocked by
billing), installation from GitHub by a real tag, and a first real app (Qeet ID Auth is React Native).

## Phase 6 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 iPhone simulator:

- **Audit** of every component across accessibility, localization, performance, reliability, security
  and privacy, API stability, tests, tokens, documentation and CI. The findings, each fixed with a
  regression test or recorded as a gap, are in `Documentation/Quality/PHASE_6_AUDIT.md`.
- **Fixes:** the password field's touch target; icons and the select at the largest text sizes; the
  right-to-left timeline connector; cached text resolution; the open set of icon names (ADR 0016, the one breaking change); workflow actions pinned by
  commit; a named web metric; two showcase targets and labels.
- **Gates:** Apple's accessibility audit over every showcase page (`AccessibilityAuditUITests`), source
  compatibility against the target branch (`Scripts/api-compat.sh`), and pinned actions.
- **Reports** in `Documentation/Quality/` and a ui.qeet.in handoff.

Not done, by scope: new components, and Phase 7's documentation site and release.

Still to verify — the release-readiness gaps (`Documentation/Quality/RELEASE_READINESS_GAPS.md`):

- VoiceOver, Full Keyboard Access and Switch Control on a device;
- an iPad and an iOS 17 runtime, neither of which can be created on this Mac;
- performance on a device;
- the CI workflow on GitHub, where Actions are blocked by billing.

## Phase 5 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 iPhone simulator:

- **Components:**
  - list rows, with `qeetrixListRow()` and the section header;
  - the description list;
  - the accordion and its disclosure style;
  - the empty state, the data state and the skeleton;
  - chips and chip groups;
  - the timeline.
- **Search** is native `searchable`, with the no-results state and chips; there is no wrapper.
- **Tests:** behaviour tests, snapshot specimens (compared locally), UI tests (including reflow at an
  accessibility size), and a 5,000-row scrolling measurement on the simulator.
- **Decisions and handoffs:** ADR 0015 and a ui.qeet.in handoff.

Deferred, with the reasons in ADR 0015:

- a data table (native `Table` on iPad; rows and a description list on iPhone);
- image presentation (`Image`, `AsyncImage`, `.aspectRatio`).

Not done, by scope: the web's `Feed`, `TreeView`, `FilterBar`, `Pagination`, `Stat` and charts.

Still to verify:

- VoiceOver speech for rows, accordions and the data state on a device;
- performance on a device (the simulator figures are not a device's);
- an iPad, an iOS 17 runtime, and the CI workflow on GitHub.

## Phase 4 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 iPhone simulator:

- **Components.**
  - Tabs.
  - Navigation and tab bar styling.
  - Alert and confirmation dialogs.
  - The sheet and its layout.
  - Popover, menu and menu item.
  - Toast.
  - `Image(qeetrix:)` for system chrome.
- **Their tests:** behaviour tests, snapshot specimens for what Qeetrix draws (recorded and compared
  locally), and UI tests for presentation, dismissal, roles and the toast lifecycle.
- **Documentation:** DocC pages, the showcase pages, and an overlay-patterns page.
- **Decisions and handoffs:** ADR 0014 and a ui.qeet.in handoff.

Deferred, with the reasons in ADR 0014:

- a separate centred `QeetrixDialog` (the sheet is the dialog);
- `QeetrixSnackbar` (the toast with an action covers it);
- the inline `QeetrixAlert`;
- a stack of toasts;
- styling the system menu surface (`component.menu`).

Not done, by scope:

- the web's `NavigationMenu`, `Sidebar`, `Breadcrumb`, `Pagination`, `HoverCard`, `Tooltip`, `Tour` and
  `FloatingWindow`;
- Phase 5's data display.

Still to verify:

- VoiceOver speech for toasts, tabs and dialogs on a device;
- Full Keyboard Access in overlays;
- an iPad, where no simulator was available (regular width was checked through an iPhone in landscape);
- an iOS 17 runtime;
- the CI workflow on GitHub.

## Phase 3 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 Simulator: the field layer and eight inputs, the form
patterns, their behaviour tests, snapshot specimens (recorded and compared locally), UI tests, DocC pages
and showcase pages, and ADRs 0012 and 0013.

Not done, by scope: date and time pickers, combobox, multi-select, currency, masked, tag and mention
inputs, file upload, rich text, and Phase 4's navigation, overlays and feedback.

Still to verify: VoiceOver speech for field hints, attached messages and announcements; Password and
one-time-code AutoFill on a device; an iOS 17 runtime; the CI workflow on GitHub.

## Phase 2 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 Simulator:

- **Components.** The eleven above, each with its style where SwiftUI has one, behaviour tests, a
  specimen in the snapshot matrix, a DocC page with compiled examples, and a showcase page.
- **Component tokens.** Eight groups adopted: avatar, badge, button, card, input, progress, switch,
  typography (ADR 0011).
- **Tooling.** `Scripts/new-component.sh` and `Templates/Component/`; the snapshot target (ADR 0009);
  the showcase's XCUITest target; gates for warnings, dependencies and licences, and resources;
  `Scripts/check.sh`.
- **Decisions.** ADR 0009 accepted; ADR 0010 (component API) and ADR 0011 (component tokens and web
  metrics).

Not done in Phase 2, by scope:

- the other 125 of the web's 137 components (the text field covers two, `input` and `field`), and the
  33 component token groups not yet adopted;
- interactive or focus-visible states that need a person to judge (Full Keyboard Access focus order);
- package releases and distribution.

Still to verify, as for Phase 1: an iOS 17 runtime, a person using VoiceOver on a device, and the CI
workflow on GitHub-hosted runners.

## Phase 1 — what is done and what is not

Done, and verified:

- **Pipeline.** Sync and lock from upstream, deterministic generation, and drift and API checks.
- **Generated tokens.** 217 tokens: 84 semantic colours, 14 elevations, 9 typography roles and the
  dimension and motion scales.
- **Fonts.** Qeet Sans and Fira Code, bundled as the web's exact fonts in native TTF.
- **Icons.** 12 icons, with their round, sharp, outline and filled drawings where upstream has them.
- **Tests.** 48 library tests on the Mac and on the iOS 27.1 Simulator, and 29 generator tests.
- **Example.** The showcase app.
- **Groundwork for Phase 2.** Decision records, and the component contract (catalogue, file set,
  tokens rule, test matrix). The template, the snapshot target and the components themselves wait for
  Phase 2.

Not done in Phase 1, by scope:

- components and the 216 component tokens;
- the full icon catalogue and the Qeet logos;
- gradients and z-index tokens;
- increased-contrast values, which upstream does not define yet;
- package releases and distribution.

Still to verify:

- running on an iOS 17 runtime, which has been compiled against but not run;
- VoiceOver and Bold Text on a device;
- the CI workflow on GitHub-hosted runners.
