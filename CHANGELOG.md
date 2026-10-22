# Changelog

Versions follow `Documentation/Releases/RELEASE_POLICY.md`. Nothing has been released yet: every
section below is unreleased.

## 0.1.0-rc.1 — candidate, not released (Phase 7: production readiness and release)

The first version of Qeetrix for iOS: everything in the Phase 1–6 sections below, plus what Phase 7
added to release it. Release notes: `Documentation/Releases/RELEASE_NOTES.md`.

### Added

- **An independent consumer app**, `Examples/QeetrixConsumer`, using the public API only, with UI tests
  of resources, a form, presentation, search, theme, text size, right to left and Apple's
  accessibility audit.
- **`Scripts/consumer-check.sh`** installs the package into that app by URL and version, from a
  throwaway tagged repository, then tests it and builds it for devices; CI runs it (`consumer` job).
- **`Scripts/release-check.sh`** runs every release gate and keeps the evidence. The hand-run "Release
  candidate verification" workflow runs it on GitHub; neither publishes anything.
- **`Scripts/sbom.sh`** (`qeetrix-gen sbom`) writes the release's CycloneDX bill of materials; each pin
  in `Upstream/pins.json` records its reviewed licence.
- **Release documents** in `Documentation/Releases/`: policy, support, distribution, checklist,
  rollback, licensing, compatibility matrix, consumer integration, the candidate report and release
  notes. Also `.github/SECURITY.md` and ADR 0017.
- **DocC:** *Installing and updating*, *Migrating* and *Troubleshooting* articles.

### Fixed

- **The icon artwork's notice now travels with the library** (licensing, P2). The MIT notice for
  `qeetrix-icons`, with Lucide's ISC and Feather's MIT notices, is pinned into the resource bundle at
  `Licenses/qeetrix-icons-LICENSE.txt`, as the fonts' licences already were. Until now an app shipping
  the icons didn't carry it.
- **The accessibility gate measured a moving layout** (TEST-2). The Dynamic Type check ran in the same audit
  call as the contrast check and re-laid out scrolled screens under it, so every heading "failed"
  contrast in the release dry run. Dynamic Type now runs in its own pass, and the gate waits for the screen
  to be still after each swipe.
- **Swift 6 data-race warnings in a UI test** (CI-2): `PopoverUITests` reset the orientation off the main
  actor. CI and the release check now build the UI tests with warnings as errors, not only the app.

### Changed

- *Getting Started* installs by version (`.upToNextMinor(from: "0.1.0")`) instead of `main`.

## Unreleased — Phase 6: quality, accessibility and performance hardening

No new components. The audit and its findings are in `Documentation/Quality/PHASE_6_AUDIT.md`.

### Breaking

- **`QeetrixIconName` is a struct, not an enum** (ADR 0016), so adding an icon is no longer a breaking
  change. Every use of a name compiles unchanged — `QeetrixIcon(.bell)`, `rawValue`, `allCases`, and
  `case .bell:` in a `switch` with a `default`. **Migration:** a `switch` over icon names without a
  `default` case needs one.

### Fixed

- **Password field target** (A11Y-1): a tap on the field's padding, or just outside a field drawn
  shorter than 44 pt, focuses it, as for the text field. The element was 19–20 pt tall.
- **The largest text sizes** (A11Y-5, A11Y-6): the select's value wraps instead of being cut to one
  line; icon buttons, icon-only menus, the password eye and the number field's steppers grow with
  their icon instead of letting it spill over their edge (`qeetrixIconSquare`), and nothing changes at
  the default size; the busy indicator scales like the icon it replaces; the checkbox mark and the
  avatar's fallback icon keep the fixed size of their boxes.
- **Right-to-left timeline** (LOC-3): the connector between markers now mirrors with them; it stayed on
  the left, through the times.
- **Text performance** (PERF-1): a resolved typeface is cached by role, size and Bold Text, instead of
  being rebuilt from a variable font on every view update — about 95 times faster on the simulator
  and 70 times on the Mac host (`PERFORMANCE_REPORT.md`).
- `max-w-sm` (384 pt) is a named web metric, `QeetrixWebScale.containerSM`, not a literal in two places
  (DESIGN-1).
- Showcase: the app-navigation link is a 44 pt target (A11Y-2); "Native button" is "Native style", a
  label that doesn't repeat its trait (A11Y-3).

### Added

- **Accessibility audit gate.** `AccessibilityAuditUITests` runs Apple's audit on every showcase page —
  light, dark, and the largest accessibility size — and fails on any issue not excluded with a reason.
- **Source-compatibility gate.** `Scripts/api-compat.sh <revision>` runs Swift's
  `diagnose-api-breaking-changes`; CI runs it on pull requests against the target branch. Breaks a
  decision record accepted are listed in `Documentation/API/breaking-changes-allowlist.txt`.
- **Workflow actions pinned by commit** (SEC-1), checked by `Scripts/dependencies.sh`.
- **Tests:** the type cache's equivalence and bound; rendering timings; script fallback for Devanagari,
  Tamil, Arabic and Bengali; the timeline dots' 3:1 contrast; the icon-name contract; right-to-left
  connector pixels; a textarea focused from its box; icons, the select and the checkbox at the largest
  text size; text in lists and grids measured scaling.
- **Reports** in `Documentation/Quality/`: the audit, component maturity, accessibility, localization,
  performance, security and privacy, API compatibility, test coverage and release-readiness gaps; ADR
  0016; and a ui.qeet.in handoff (`Documentation/Website/PHASE_6_HANDOFF.md`).

## Unreleased — Phase 5: data display, collections and content states

Built from `@qeetrix/ui` 2.1.6 (`7d7f651`) and `@qeetrix/icons` 1.0.11, unchanged; three more component
token groups and eight more icons adopted from them.

### Added

- **List rows.** `QeetrixListItem` (title, description, metadata, leading and trailing views, selection),
  `QeetrixListItemIcon`, `.qeetrixListRow()` for rows wrapped in a link or button,
  `QeetrixListItemButtonStyle` (`.buttonStyle(.qeetrixListItem)`) outside a list, and
  `QeetrixSectionHeader` for native sections.
- **Description list.** `QeetrixDescriptionList` (`horizontal`, `vertical`, `grid`; `isDivided`) and
  `QeetrixDescriptionItem`.
- **Accordion.** `QeetrixAccordion`, `QeetrixAccordionItem` and `QeetrixDisclosureGroupStyle`
  (`.disclosureGroupStyle(.qeetrix)`) for any `DisclosureGroup`.
- **Content states.** `QeetrixEmptyState` (`default`, `firstUse`, `noResults`, `noPermission`, `error`;
  `sm`, `default`, `lg`), `QeetrixDataState` with `QeetrixDataFailure` and `QeetrixDataLoadingRows`, and
  `QeetrixSkeleton` (`rectangle`, `circle`, `capsule`) with `QeetrixSkeletonText`.
- **Chips.** `QeetrixChip` (toggle or removable; `sm`, `md`, `lg`) and `QeetrixChipGroup` (one value or a
  `Set`).
- **Timeline.** `QeetrixTimeline` and `QeetrixTimelineItem`, with `QeetrixTimelineTone` and
  `QeetrixTimelineEmphasis`.
- **Component tokens.** The `accordion`, `skeleton` and `timeline` groups (thirteen adopted in all). The
  generator now emits component durations as `QeetrixDuration`.
- **Icons.** calendar, clock, file-text, folder, mail, refresh-cw, search-x and users (37 in all).
- **Built-in strings.** "Remove" and "Something went wrong while loading this data." (qeetrix-ui), and
  "Try again", "Expanded" and "Collapsed" (iOS).
- **Showcase.** Pages for list rows, search and filter, the description list, chips, the timeline,
  collection patterns, 5,000 rows, the skeleton, the empty and data states and the accordion.
- **Tests.** Behaviour tests, snapshot specimens, UI tests — including reflow at an accessibility size —
  and a scrolling and memory measurement over 5,000 rows.
- **Documentation.** DocC pages for each component, the *Building collections* and *Searching a
  collection* articles, ADR 0015, and a ui.qeet.in handoff (`Documentation/Website/PHASE_5_HANDOFF.md`).

### Changed

- `QeetrixOption` also serves `QeetrixChipGroup`.

## Unreleased — Phase 4: navigation, overlays and feedback

Built from `@qeetrix/ui` 2.1.6 (`7d7f651`) and `@qeetrix/icons` 1.0.11, unchanged; two more component
token groups and eight more icons adopted from them.

### Added

- **Tabs.** `QeetrixTabs`, `QeetrixTab` and `QeetrixTabsVariant` (`default`, `line`): the selection is a
  binding the app owns; a strip wider than its container scrolls and keeps the selection in view;
  labels never truncate; the strip carries the tab-bar trait.
- **Navigation chrome.** `qeetrixNavigationBar(background:)` (`QeetrixNavigationBarBackground`),
  `qeetrixTabBar()` and `qeetrixTabItem(_:icon:badge:)` style the system navigation and tab bars.
- **Dialogs.** `QeetrixAlertDialog` and `QeetrixConfirmationDialog`, presented from an optional value with
  `qeetrixAlertDialog(_:)` and `qeetrixConfirmationDialog(_:)`; `QeetrixDialogAction` with the system
  `ButtonRole`. A tap clears the value, then runs the action once; a destructive action without a cancel
  gets "Cancel".
- **Sheet.** `qeetrixSheet(isPresented:detents:isDismissDisabled:onDismiss:content:)` and its `item:`
  form, on the `component.dialog` surface; `QeetrixSheetContent` lays out the title, description, Close
  (with `onClose` to confirm discarding changes), scrolling content and pinned actions.
- **Popover.** `qeetrixPopover(isPresented:arrowEdge:compactAdaptation:content:)` on the
  `component.popover` surface.
- **Menu.** `QeetrixMenu` (a Qeetrix button trigger, titled or icon-only) and `QeetrixMenuItem` (a Qeetrix
  icon and a role), for the system menu and context menus.
- **Toast.** `QeetrixToast`, `QeetrixToastType` and `qeetrixToast(_:)`: one toast at a time, replaced by
  the next; repeats re-timed, not re-announced; 5 s or 10 s as on the web, `.zero` to persist; held while
  VoiceOver's focus or a pointer is on it, and kept while VoiceOver runs if it has an action; errors
  announced at high priority; the timer ends with the view.
- **`Image(qeetrix:size:shape:variant:stroke:)`**: a Qeetrix icon as a template image for tab items,
  toolbars and menus.
- **Component tokens.** The `dialog` and `popover` groups (ten adopted in all).
- **Icons.** circle-x, copy, ellipsis, house, pencil, settings, share-2 and trash (29 in all).
- **Built-in strings.** "Close" (qeetrix-ui `overlayMessages.close`, `toastMessages.close`) and "Cancel"
  (iOS).
- **Showcase.** Pages for tabs, app navigation, the alert and confirmation dialogs, sheets, popovers,
  menus and toasts, and an overlay-patterns page (menu → confirmation → toast with undo; sheet → save →
  toast).
- **Tests.** Unit tests for the dialog rules, the toast lifecycle (`QeetrixToastState`) and policy, tabs,
  sheet, popover, menu and icon images, and the compiled documentation examples; snapshot specimens for
  what Qeetrix draws; UI tests for every component's presentation, dismissal and roles.
- **Documentation.** DocC pages for each component, the *Choosing an overlay* and *Navigation and tab
  bars* articles, ADR 0014, and a ui.qeet.in handoff (`Documentation/Website/PHASE_4_HANDOFF.md`).

### Fixed

- `QeetrixNumberField` follows a number with a trailing decimal separator while typing: "-12." now sets
  -12. Keystrokes can reach the field together, so it could see "-12." without "-12" and keep -1 (found
  by a UI test that failed depending on timing).
- Two flaky number-field UI tests:
  - `clearAndType` puts the caret after the text before deleting it, because a tap could land before the
    centred digit.
  - The clamping test no longer assumes which in-range values were taken on the way to "900"; it checks
    that "900" never is, and that committing gives 250.

## Unreleased — Phase 3: inputs and forms

Built from `@qeetrix/ui` 2.1.6 (`7d7f651`) and `@qeetrix/icons` 1.0.11, unchanged.

### Added

- **Field.** `QeetrixField` — label, required or optional mark, control, description and message for any
  control — and `QeetrixFieldSet` for a group under a legend. Every input builds on the same field, and
  its native control carries the field for VoiceOver: the label (and "Required") as its name, the
  description as its hint, the message as content read with it; new messages are announced (ADR 0012).
- **Inputs**, each on the system control:
  - `QeetrixTextarea` — multi-line, growing to 15 lines then scrolling.
  - `QeetrixPasswordInput` and `QeetrixPasswordPurpose` — `SecureField`, Password AutoFill, a reveal toggle
    that keeps the keyboard and text.
  - `QeetrixOTPInput` and `QeetrixOTPCharacters` — one native one-time-code field drawn as cells: AutoFill,
    paste, leading zeros, completion once.
  - `QeetrixCheckbox` and `QeetrixCheckboxToggleStyle` (`.toggleStyle(.qeetrixCheckbox)`), with the mixed
    state.
  - `QeetrixRadioGroup` and `QeetrixSelect` (the system menu), sharing `QeetrixOption<Value>`.
  - `QeetrixNumberField` — `Int?` or `Decimal?`, locale-aware, in-between states kept while typing,
    clamped and rounded on commit, steppers.
- **Form patterns.** `QeetrixFormActions` (stacked on compact width, a trailing row otherwise) and
  `QeetrixFormErrorSummary` (an alert summary whose links focus their fields); the `Forms` article.
- **Icons.** chevron-down, eye-off, minus and plus (21 in all).
- **Built-in strings.** "(optional)", "Show password", "Hide password", "One-time code", "Decrease",
  "Increase", "There is a problem" (from the web catalogue), and "Error", "Warning", "Success" (iOS).
- **Tests.** 35 library tests (behaviour, and the compiled documentation examples), 9 snapshot specimens
  (36 images), and UI tests for every input and the form patterns, including focus moving through an
  app's `@FocusState`.
- **Showcase.** A page per input and a form-patterns page (registration- and settings-style).
- **Decisions.** ADR 0012 (form components) and ADR 0013 (snapshot baselines stay local).

### Changed

- `QeetrixTextField` is built on `QeetrixField` and gains `isOptional:` (defaulted, so existing calls
  compile unchanged); its look is unchanged, as its Phase 2 snapshots confirm. Its description is now
  also its VoiceOver hint, and its message is attached to it.
- `QeetrixSwitch` rows sit flush in a `QeetrixFieldSet`.
- **Screenshots are never committed.** `.gitignore` excludes the snapshot baselines and image files;
  baselines are recorded locally, and CI builds the snapshot target without comparing (ADR 0013).
  `Scripts/resources.sh` accepts a checkout without baselines.
- The scaffold's tests use Slider as their example of a component not yet built.

### Fixed

- `QeetrixProgress`: the indeterminate segment's path is cut to the track, so the bar's VoiceOver frame
  never reaches past the screen edge. The Phase 2 fix (a shape instead of an offset view) still let the
  path's bounds extend during the sweep, which a UI test caught depending on its timing.
- Error-summary links are full 44 pt rows: extended hit areas on links 4 pt apart sent a tap to the
  neighbouring link (found by a UI test).

## Unreleased — Phase 2: core components

Built from `@qeetrix/ui` 2.1.6 (`7d7f651`) and `@qeetrix/icons` 1.0.11, unchanged from Phase 1.

### Added

- **Components**, each following its web counterpart's variants, sizes and states:
  - `QeetrixText` and `QeetrixTextVariant` — the web Typography variants, headings as VoiceOver headings.
  - `QeetrixSeparator` and `QeetrixSeparatorVariant`.
  - `QeetrixCard`, `QeetrixCardHeader`, `QeetrixCardVariant`, `QeetrixCardSize` and
    `QeetrixCardButtonStyle` (`.buttonStyle(.qeetrixCard())`) for a card that is the control.
  - `QeetrixBadge` and `QeetrixBadgeVariant`.
  - `QeetrixButton`, `QeetrixButtonVariant`, `QeetrixButtonSize` and `QeetrixButtonStyle`
    (`.buttonStyle(.qeetrix())`), with icons and a loading state that keeps width and colour.
  - `QeetrixIconButton`, with a required accessible label.
  - `QeetrixSpinner` and `QeetrixSpinnerSize`.
  - `QeetrixProgress`, `QeetrixProgressSize` and `QeetrixProgressViewStyle`
    (`.progressViewStyle(.qeetrix())`), determinate and indeterminate.
  - `QeetrixAvatar`, `QeetrixAvatarSize` and `QeetrixAvatarShape`, with initials, a fallback icon and a
    status badge.
  - `QeetrixSwitch`, `QeetrixSwitchSize` and `QeetrixSwitchToggleStyle` (`.toggleStyle(.qeetrixSwitch())`).
  - `QeetrixTextField` and `QeetrixFieldMessage`: label, prompt, description, error, warning and success
    messages, required, read-only and disabled.
- **Component tokens** for avatar, badge, button, card, input, progress, switch and typography, generated
  as internal `Qeetrix<Group>Tokens` (ADR 0011). The generator keeps semantic references and density
  lookups as such, and fails on a pinned group upstream does not define.
- **Icons.** circle-alert, circle-check, loader-circle, triangle-alert and user-round (17 in all).
- **Built-in strings** in `Resources/Localization/en.lproj` ("Loading", "Required"); the package now
  declares `defaultLocalization: "en"`.
- **Snapshot tests.** `QeetrixSnapshotTests` with Point-Free SnapshotTesting 1.19.6 (test-only, exact):
  one specimen per component in light, dark, AX3 and right-to-left (ADR 0009, now accepted). 44 baselines.
- **UI tests.** `QeetrixShowcaseUITests`: taps, loading, disabled, toggles, typing, validation
  messages, 44 pt targets, and VoiceOver names, values and traits.
- **Showcase.** An index grouped by the ui.qeet.in categories, a page per component, and `-page <id>`.
- **Scaffold.** `Scripts/new-component.sh` and `Templates/Component/`, tested in temporary copies of the
  repository.
- **Gates.** `Scripts/warnings.sh` (no compiler warnings), `Scripts/dependencies.sh` (allowlisted,
  test-only dependencies with reviewed licences), `Scripts/resources.sh` (strings and baselines), and
  `Scripts/check.sh` for all host gates. CI gains snapshot and UI-test jobs.
- **Documentation.** A DocC page per component with compiled examples; ADR 0010 and ADR 0011; the
  component contract, accessibility standard, architecture and contributing guide brought up to date.

### Changed

- Typography resolves roles and component text styles through one internal type, so components get
  the same Dynamic Type and Bold Text handling as `qeetrixTextStyle(_:)`. No public API changed.
- Two Phase 1 icon tests now run on the main actor, as Swift 6.4 requires.

## Unreleased — Phase 1: foundations

Built from `@qeetrix/ui` 2.1.6, `@qeetrix/icons` 1.0.11 (`331cd85`), Cal Sans v2.011 and Fira Code 6.2.

### Added

- **Token pipeline.** `Tools/QeetrixGen` (the `qeetrix-gen` tool, run through `Scripts/`) does the
  following:
  - syncs the published `@qeetrix/ui` token build, the native fonts and the pinned icons into
    `Upstream/`, verified and locked by sha256;
  - generates typed Swift from them;
  - verifies generated files byte-for-byte.
  It needs no dependencies and runs offline after a sync.
- **Colour.** `QeetrixColor`: the 84 semantic colours as a `ShapeStyle` resolving light or dark from
  the environment. OKLCH is converted per CSS Color 4: sRGB where possible, Display P3 where the web's
  colour is wider.
- **Theme.**
  - `QeetrixThemeMode` (`light`, `dark`, `system`; the same raw values as the web) and
    `.qeetrixThemeMode(_:)`.
  - `QeetrixTheme` with `@Environment(\.qeetrixTheme)`, and `.qeetrixTheme(_:)` for subtree overrides.
- **Typography.**
  - `QeetrixTextRole` (display, title, heading, body, label, label-compact, caption, micro, code) and
    `.qeetrixTextStyle(_:)`.
  - Dynamic Type scaling, the variable-font axes (weight, letter style, optical size) set as on the web,
    and one weight step heavier under Bold Text.
  - `QeetrixFontRegistry` and `QeetrixTextMetrics`.
- **Fonts.** Qeet Sans (Cal Sans VF) and Fira Code VF as TTF, each proven identical to the font the
  web ships, with their OFL licences.
- **Scales.** `QeetrixSpacing`, `QeetrixCorner`, `QeetrixStroke`, `QeetrixFocus`, `QeetrixOpacity`,
  `QeetrixDensity` (with `\.qeetrixDensity`), `QeetrixIconSize` and `QeetrixIconStroke`.
- **Elevation.** `QeetrixElevation` and `.qeetrixElevation(_:fill:in:)`, drawing the web's
  `box-shadow` layers: spread, the ring layer and inset highlights.
- **Motion.** `QeetrixDuration`, `QeetrixEasing`, `QeetrixMotion.animation(_:_:reduceMotion:)` and
  `.qeetrixAnimation(_:_:value:)`, which honour Reduce Motion.
- **Icons.**
  - `QeetrixIcon` and `QeetrixIconName`: 12 icons (bell, check, database, eye, inbox, info, lock,
    navigation, search, send, server, x) in round and sharp, outline and filled where drawn.
  - Decorative by default, labelled for VoiceOver, Dynamic Type scaling, and right-to-left mirroring.
- **Accessibility.** `QeetrixAccessibility.minimumTouchTarget`, `.qeetrixMinimumTouchTarget()` and
  `contrastRatio(_:on:)`.
- **Provenance.** `QeetrixProvenance.bundled()`, backed by `Resources/Metadata/token-provenance.json`.
- **Showcase.** `Examples/QeetrixShowcase`, an iOS app showing every foundation.
- **Tests.**
  - 48 library tests: token parity with upstream, brand colour values, upstream's WCAG pairs in both
    themes, font loading and axes, rendering, theme overrides, icons, the public API and the
    documentation examples.
  - 29 generator tests.
- **Repository layout** (ADR 0007): the generator in `Tools/QeetrixGen`, its pinned inputs and lock in
  `Upstream/`, and the commands in `Scripts/`.
- **Decision records** in `Documentation/Decisions/` (0001–0008 accepted, 0009 proposed), and the
  component contract for Phase 2 in `Documentation/Standards/COMPONENT_CONTRACT.md`.
- **Governance.** `SECURITY.md`, `.editorconfig`, `.github/CODEOWNERS`, a pull request template, and
  issue templates for bugs and design-system changes.
- **Documentation.** The DocC catalogue `Sources/Qeetrix/Qeetrix.docc`: a landing page and guides for
  getting started, theming, typography, spacing, shapes, sizing, elevation, motion, icons and
  accessibility. It is built with warnings as errors (`Scripts/docs.sh`, and in CI), and its examples
  are compiled by the tests.
- **Checks and CI.** `Scripts/lint.sh` (swift-format), `Scripts/api-check.sh` (public API baseline) and
  `.github/workflows/ci.yml`.
