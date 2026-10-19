# Changelog

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
