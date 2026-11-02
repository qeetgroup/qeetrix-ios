# Changelog

Versions follow `Documentation/Releases/RELEASE_POLICY.md`. Nothing has been released yet: every
section below is unreleased.

## Unreleased — the iOS component tickets (QTRX-95 to QTRX-155)

New components for every iOS app built on Qeetrix, and for the native Qeet Auth, each with tests, a
DocC page and a showcase page, following `@qeetrix/react` 0.4.0 where it has a counterpart. 38 more icons are pinned for them (68 in
all). Merged with Phases 5–7 on 2026-11-02: the list item, section header, description list,
accordion, empty and data states, skeleton, chip and timeline replace Phase 5's implementations, so
their initialisers change (source-breaking against Phase 5, ADR 0018); `QeetrixIconName` keeps Phase
6's open set (ADR 0016).

### Added

- **Haptics** (QTRX-152): `QeetrixFeedback` — selection, success, warning, error and light impact — on
  SwiftUI's `sensoryFeedback`, with `.qeetrixFeedback(_:trigger:)` and `play()`; silent when System
  Haptics is off. `QeetrixSwitch`, `QeetrixCheckbox` and `QeetrixRadioGroup` play selection feedback
  when a person changes them, not when the app does.
- **Format** (QTRX-139): `QeetrixFormat`, `@qeetrix/react`'s format family (number, currency, percent,
  compact, date, date and time, relative time) plus time, all-number dates, ranges, file sizes and
  durations, with the web's rounding, Gregorian dates and en-IN's lakh grouping; 1,977 cases in 19
  locales are checked against the web's output, and the differences Apple's locale data makes are
  listed and pinned. `QeetrixRelativeTime` keeps "2 minutes ago" current on screen.
- **List item and section header** (QTRX-95): `QeetrixListItem` — a leading avatar or icon, a title, a
  description and a value; a chevron, a switch or trailing content; a destructive role; the selected
  tint — in a `List` (`.qeetrixListStyle()`) or a stack, at least 44 pt, read as one element.
  `QeetrixSectionHeader` labels a group.
- **Description list** (QTRX-99) and **check list** (QTRX-149): `QeetrixDescriptionList` (rows that
  stack or sit side by side by width, or 1–4 columns; each pair one element) and `QeetrixCheckList`
  (passed, failed, not run and running, in an icon and in words; changes announced).
- **Alert** (QTRX-111): `QeetrixAlert` in info, success, warning and danger, with an optional dismiss,
  actions and announcement; `QeetrixErrorSummary` is drawn by the same surface.
- **Empty and data state** (QTRX-97), **skeleton** (QTRX-98), **timeline** (QTRX-100) and **steps**
  (QTRX-141): `QeetrixEmptyState`, `QeetrixDataState` (loading, failure with Try again, empty, content),
  `QeetrixSkeleton` (hidden from VoiceOver; its group reads "Loading"), `QeetrixTimeline` (28 pt
  markers, six tones, a compact variant) and `QeetrixSteps` (done, current, upcoming, failed,
  attention; a compact "Step 2 of 4" form on narrow screens).
- **Chip and chip group** (QTRX-117): `@qeetrix/react` 0.4.0's Chip and ChipGroup — selectable or
  removable, one value or several, wrapping or scrolling.
- **Segmented control** (QTRX-112), **accordion** (QTRX-118), **page indicator** (QTRX-154) and
  **avatar group** (QTRX-147): `QeetrixSegmentedControl`, `QeetrixAccordion` (the app owns which
  sections are open), `QeetrixPageIndicator` (an adjustable "Page 2 of 4") and `QeetrixAvatarGroup`.
- **Circular progress** (QTRX-109): `QeetrixCircularProgress`, a determinate ring on Progress's track
  and tones plus warning, for a value or a timer interval; one step a second under Reduce Motion.
- **QR code** (QTRX-143): `QeetrixQRCode`, with the web's encoder ported so the modules match the web's
  for the same value and level; dark on white in either scheme.
- **QR scanner** (QTRX-110) and **permission primer** (QTRX-153): `QeetrixQRScanner` over the app's own
  camera preview (no AVFoundation in Qeetrix) — target, torch, guidance, the camera's permission states
  and "Type the key instead" — and `QeetrixPermissionPrimer`, Continue / Not now before the system
  prompt and Open Settings once denied.
- **Bottom action bar** (QTRX-150) and **full-screen form** (QTRX-151):
  `.qeetrixBottomActionBar(primary:secondary:)` above the keyboard and home indicator, and
  `QeetrixFullScreenForm`, which asks before throwing changes away and is a form sheet on a tablet.
- **Large title** (QTRX-155), **sidebar and detail** (QTRX-119) and **search field** (QTRX-96):
  `.qeetrixNavigationBar(background:title: .qeetrix)`, `QeetrixNavigationScaffold` (a tab bar at
  compact width, a sidebar beside the detail at regular width) and `QeetrixSearchField` with
  `.qeetrixSearchable(…)`.
- **Copy button and copy field** (QTRX-140): `QeetrixCopyButton` and `QeetrixCopyField`, confirmed by a
  check, a light haptic and a "Copied" toast through the screen's toast binding; `isSensitive` keeps
  the pasteboard entry on the device and removes it after 60 seconds.
- **OTP code** (QTRX-108): `QeetrixOTPCode` — a one-time code in Fira Code, grouped 123 456 or
  1234 5678, with its countdown ring turning warning in the last 5 seconds, tap to copy (local only,
  60 seconds), and the digits read one by one, then the time left; the app computes the code.
- **Swipe actions** (QTRX-113) and **pull to refresh** (QTRX-114): `.qeetrixSwipeActions(…)` with
  `QeetrixSwipeAction` — the system's swipe in Qeetrix's tones, a confirmation before a danger action,
  and the same actions for VoiceOver and in the row's context menu — and `.qeetrixRefreshable(…)`,
  which says "Updated" (or the app's words) when the system's refresh finishes.
- **Date picker and range** (QTRX-138): `QeetrixDatePicker` (the system's graphical calendar in
  Qeetrix's tint, or `QeetrixCalendar` when days are ruled out), `QeetrixDateRangePicker` with presets,
  and `QeetrixCalendar` and `QeetrixRangeCalendar`, with 44 pt days, year and month views, and keyboard
  and VoiceOver navigation.
- **Time picker** (QTRX-146): `QeetrixTimePicker`, the system's time wheel with a minute step, in 12 or
  24 hours as the device is set.
- **Stat** (QTRX-142) and **slider** (QTRX-148): `QeetrixStat` and `QeetrixStatGroup` (formatted values,
  a change up or down said in words, the web's trend line, skeleton loading) and `QeetrixSlider` (one
  value or a range, each thumb a 44 pt adjustable element).
- **Searchable picker** (QTRX-144): `QeetrixCombobox`, a choice from a long list in a sheet behind the
  Select's trigger, with search that ignores case, accents and width, groups, one or several choices,
  and "No matches".
- **Attachments** (QTRX-145): `QeetrixFileUpload` and `QeetrixFileRow` — files from Photos, the camera
  or Files through the system's pickers, checked for type, size and number in the web's words, a row
  per file with its icon, size, progress, outcome and Remove; the app owns the files and the uploads.

### Changed

- The resource check counts a built-in string looked up as `String(localized:defaultValue:bundle:)` or
  `LocalizedStringResource(_:defaultValue:bundle:)`, the forms a string with arguments takes.
- `@qeetrix/react`'s `combobox` CSS is pinned as the searchable picker's reference (55 families).
- The showcase declares its camera use, so the attachment picker offers the camera on a device.

### Fixed

- A `QeetrixButton` with an icon no longer stretches to share the spare height of a stack it sits in
  (its icon zone filled the height on offer, so the button grew with it, as the QR scanner's fallback
  did). A wrapped label still gets its room above and below at the accessibility sizes.

## Unreleased — the move to `@qeetrix/react`

Built from `@qeetrix/tokens` 0.0.13 (`4483f96`), `@qeetrix/icons` 2.1.0 (`e2a8f9f`) and
`@qeetrix/react` 0.4.0 (`9a765bb`), all from npm and checked against the registry's integrity hashes.
`@qeetrix/ui` is no longer used. Every old name and its new one is in
[`Documentation/MIGRATION_QEETRIX_REACT.md`](Documentation/MIGRATION_QEETRIX_REACT.md); the decision
is ADR 0018. **Source-breaking**: most component initialisers, every token type and the provenance
record changed.

### Changed

- **Tokens** are generated from `@qeetrix/tokens`' DTCG build, resolved as its resolver says (light
  and dark × default, comfortable and compact), and checked against the package's pre-resolved files
  and `tokens.css`. 194 tokens generated, 145 excluded with a reason. Types renamed to the token
  groups: `QeetrixSpacing` → `QeetrixSpace`, `QeetrixCorner` → `QeetrixRadius`, `QeetrixStroke` →
  `QeetrixBorderWidth`, `QeetrixElevation` → `QeetrixShadow` (`.qeetrixElevation` →
  `.qeetrixShadow`); `QeetrixColor` and `QeetrixTextRole` take the new paths' names (109 colours, 18
  roles); `QeetrixDensity` gives `sizeControlSm/Md/Lg`, `sizeRow`, `spaceFormGap`. New:
  `QeetrixSpring`, `QeetrixSize.targetMin`, `QeetrixControlSize`. `QeetrixMotion.reducedEasing` is
  gone. Every value is listed per context in `Documentation/Foundations/token-values.json`.
- **Typography** follows `@qeetrix/react`: each role's letter style on the `GEOM` axis, optical
  sizing, CSS half-leading (the role's line on every line), Bold Text one weight step up. The letter
  style and the exact line height come from each role's token (`$extensions["in.qeet.qeetrix"]`), so
  every line height is a whole number of points on the 4 pt grid (`body.md` 20 pt, was 20.0004).
- **Fonts** are the TTFs `@qeetrix/tokens` ships for native platforms (`QeetSans.ttf`,
  `FiraCode-VF.ttf`), checked against the sha256 and size in its `fonts/native.json`. The previous
  fonts came from the font projects' releases; the faces are the same.
- **Icons** come from `@qeetrix/icons` 2.1.0's SVG files and JSON manifest; `chevron-right` added
  (30). Components draw the sharp shape.
- **Dark rules and the dark brand hover** (tokens 0.0.13): `borderSubtle` is #2E2E2D and
  `borderDefault` #383837 in dark (were #1E1E1E and #262625), so separators show on menus, sheets and
  popovers; dark `bgBrandBoldHover` is #C5430A (was #B73D10), 3:1 on every dark surface.
- **Components** take `@qeetrix/react`'s names and look: `variant`, `tone` and `size`
  (`QeetrixControlSize`) as the web has them, the filled field, the button's icon zone, the 3 pt tab
  bar, ruled sheets, the error summary, and the react message catalogue. Per component, old API and
  new, in the migration file. Renamed: `QeetrixFieldSet` → `QeetrixFieldset`,
  `QeetrixFormErrorSummary` → `QeetrixErrorSummary`, `QeetrixToastType` → `QeetrixToastTone`
  (`.error` → `.danger`), `QeetrixPasswordPurpose` → `QeetrixPasswordAutoComplete`,
  `QeetrixOTPCharacters` → `QeetrixOTPValidationType`. Field messages are `error: String?`; warnings
  and successes are gone, as in react.
- **A selected tab shows its icon filled by default** (`filledWhenSelected` defaults to `true`, as in
  `@qeetrix/react` 0.4.0, QTRX-168). Pass `false` to keep the outline; an icon with no filled drawing
  keeps its outline either way.
- **Dynamic Type.** Single-line controls are the web's height at the default size and scale with the
  text above it; icon buttons, steppers and icon zones grow with their icons; button labels wrap.
- **`QeetrixProvenance`** names the three packages (version, gitHead, integrity) and each font's
  package, file and hashes.
- **Folders** follow `@qeetrix/react`'s families (`Field/`, `Fieldset/`, `TextField/`, `Radio/`,
  `Menu/`, `Text/`, `Heading/`).
- The ui.qeet.in handoff is `Documentation/Website/QEETRIX_REACT_HANDOFF.md` (was
  `PHASE_4_HANDOFF.md`), with `@qeetrix/react`'s names.

### Added

- `QeetrixHeading`; `QeetrixText` sizes, weights, tones, `mono`, `truncate`, `align`.
- `tone` on buttons, icon buttons, badges, cards, separators, progress, spinners, menus and menu
  items; `isFullWidth` on buttons; `tooltip` on icon buttons.
- Text field `icon`, `startAdornment`, `endAdornment`; number-field adornments and `showsSteppers`;
  OTP `groups` and `size`; select `size` and `isReadOnly`; radio `orientation`; switch `description`;
  sheet `intent` and `isDismissible`; popover `title` and `description`; tab `filledWhenSelected` and
  `badge`.

### Removed

- `QeetrixCardHeader`, `QeetrixCardSize`, the elevated card; `QeetrixButtonSize` (use
  `QeetrixControlSize`), leading icons and `loadingLabel`; `QeetrixSwitchSize`; `QeetrixProgressSize`;
  `QeetrixTextVariant` (use `QeetrixText` and `QeetrixHeading`); `QeetrixFieldMessage`; the avatar
  `xs` size and badge; `QeetrixWebScale` and the component tokens (ADR 0011 is superseded).

### Fixed

- From `@qeetrix/react` 0.4.0: an invalid checkbox, radio or switch keeps the danger edge when checked
  and hovered, and a chosen invalid radio's ring is the danger colour (QTRX-161); the switch's on thumb
  is white in dark too, `color.icon.on-brand` (QTRX-162); read-only fields draw the editable
  `border.strong` line, which holds 3:1 (was `border.subtle`, QTRX-175); the progress track is
  `color.surface.sunken` in dark, so every tone keeps 3:1 against it (QTRX-176); a card with a header
  and no content ends at its header, with no empty body or rule (QTRX-174).
- The sync no longer converts WOFF2 to TTF: `@qeetrix/tokens` 0.0.12 ships the TTFs (QTRX-91). They
  are byte-identical to the previous conversion.
- The component manifest is read from `@qeetrix/react`'s `dist/manifest.json`, no longer from the JS
  bundle (QTRX-92).
- An avatar is one image named by its name: its initials are no longer listed inside it (iOS 26 and
  later list them under `children: .ignore`). The password input has a 44 pt target again. The tab
  rule spans the whole strip. A popover shown as a sheet starts at the top.
- A popover stays a popover in compact height (any iPhone in landscape). Before, on an iPhone that is
  compact width in landscape (iPhone SE, 16e, 17), it covered the screen with no grabber and nothing
  to tap outside, so it could not be dismissed.
- A select inside `ImageRenderer` no longer stops the process ("accessing attribute in a different
  namespace"): the menu label no longer reads Dynamic Type itself.
- Snapshot tests measure a specimen after a layout pass with its traits, and ax3 is AX3 in the
  traits as in the environment; before, larger text overflowed rows and fields measured at the
  default size.

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
