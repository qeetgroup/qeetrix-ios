# Qeetrix for iOS

The native SwiftUI implementation of **Qeetrix**, the Qeet Group design system. It gives iOS apps the
same tokens, typeface, themes and icons as the web's
[`@qeetrix/tokens`](https://github.com/qeetgroup/qeetrix-tokens) and
[`@qeetrix/icons`](https://github.com/qeetgroup/qeetrix-icons), generated from those npm packages rather
than copied from them, and components that look and behave like
[`@qeetrix/react`](https://github.com/qeetgroup/qeetrix-react)'s (ADR 0015).

**Status: Phase 4b, migrated to `@qeetrix/react` 0.4.0, with the iOS component tickets in progress.** The foundations (tokens, theming, typography,
icons, accessibility helpers), the core components, the form controls and patterns, and tabs, navigation
chrome, dialogs, sheets, popovers, menus and toasts, each with tests, a DocC page and a showcase page
([PHASES.md](PHASES.md)). Every old name and its new one:
[Documentation/MIGRATION_QEETRIX_REACT.md](Documentation/MIGRATION_QEETRIX_REACT.md).

## What is in it

| Area | API | Source |
|:--|:--|:--|
| Colour | `QeetrixColor` — 109 semantic colours, a `ShapeStyle` that resolves light/dark from the environment | `@qeetrix/tokens` `color.*` |
| Theme | `QeetrixThemeMode` (`light` / `dark` / `system`), `.qeetrixThemeMode(_:)`, `.qeetrixTheme(_:)`, `@Environment(\.qeetrixTheme)` | the resolver's colour schemes, `QeetrixProvider` modes |
| Typography | `QeetrixTextRole` (18 roles), `.qeetrixTextStyle(_:)`, `QeetrixFontRegistry` | `typography.*`, `font.geometry.*`; Qeet Sans and Fira Code TTFs |
| Spacing, size, shape | `QeetrixSpace`, `QeetrixRadius`, `QeetrixBorderWidth`, `QeetrixFocus`, `QeetrixSize`, `QeetrixDensity`, `QeetrixControlSize`, `QeetrixOpacity` | `space`, `radius`, `border.width`, `focus.ring`, `size`, the density modifier, `opacity` |
| Shadow | `QeetrixShadow`, `.qeetrixShadow(_:fill:in:)` | `shadow.*` (per scheme) |
| Motion | `QeetrixDuration`, `QeetrixEasing`, `QeetrixSpring`, `QeetrixMotion`, `.qeetrixAnimation(_:_:value:)` | `motion.*`, tokens.css's reduced motion |
| Icons | `QeetrixIcon`, `QeetrixIconName` (68 icons), `Image(qeetrix:)` for system chrome | `@qeetrix/icons` 2.1.0 |
| Accessibility | `QeetrixAccessibility.minimumTouchTarget`, `.qeetrixMinimumTouchTarget()`, `contrastRatio(_:on:)` | Apple HIG, WCAG 2.2 |

### Components

| Component | API | `@qeetrix/react` |
|:--|:--|:--|
| Text | `QeetrixText` (`size`, `weight`, `tone`, `mono`, `truncate`) | Text |
| Heading | `QeetrixHeading` (`level`, `size`, `tone`) | Heading |
| Separator | `QeetrixSeparator` | Separator |
| Card | `QeetrixCard`, `.buttonStyle(.qeetrixCard())` | Card |
| Badge | `QeetrixBadge` | Badge |
| Button | `QeetrixButton`, `.buttonStyle(.qeetrix())` | Button |
| Icon button | `QeetrixIconButton` | IconButton |
| Spinner | `QeetrixSpinner` | Spinner |
| Progress | `QeetrixProgress`, `.progressViewStyle(.qeetrix())` | Progress |
| Avatar | `QeetrixAvatar` | Avatar |
| Switch | `QeetrixSwitch`, `.toggleStyle(.qeetrixSwitch)` | Switch |
| Field | `QeetrixField` | Field |
| Fieldset | `QeetrixFieldset` | Fieldset |
| Text field | `QeetrixTextField` | TextField, Input |
| Textarea | `QeetrixTextarea` | Textarea |
| Password input | `QeetrixPasswordInput` | PasswordInput |
| OTP input | `QeetrixOTPInput` | OTPInput |
| Checkbox | `QeetrixCheckbox`, `.toggleStyle(.qeetrixCheckbox)` | Checkbox |
| Radio group | `QeetrixRadioGroup`, `QeetrixOption` | RadioGroup |
| Select | `QeetrixSelect`, `QeetrixOption` | Select |
| Number field | `QeetrixNumberField` | NumberField |
| Form | `QeetrixErrorSummary`, `QeetrixFormActions` | Form, ErrorSummary |
| Tabs | `QeetrixTabs`, `QeetrixTab` | Tabs |
| Navigation and tab bars | `.qeetrixNavigationBar(background:)`, `.qeetrixTabBar()`, `.qeetrixTabItem(_:icon:badge:)` | — (styles the system bars) |
| Alert dialog | `QeetrixAlertDialog`, `.qeetrixAlertDialog(_:)`, `QeetrixDialogAction` | Dialog (`intent` danger) |
| Confirmation dialog | `QeetrixConfirmationDialog`, `.qeetrixConfirmationDialog(_:)` | — (iOS action sheet) |
| Sheet | `.qeetrixSheet(isPresented:…)`, `.qeetrixSheet(item:…)`, `QeetrixSheetContent` | Drawer, Dialog |
| Popover | `.qeetrixPopover(isPresented:…)` | Popover |
| Menu | `QeetrixMenu`, `QeetrixMenuItem` | Menu, ContextMenu |
| Toast | `QeetrixToast`, `.qeetrixToast(_:)` | Toast |

#### Added for the iOS component tickets (QTRX-95 to QTRX-155)

| Component | API | `@qeetrix/react` |
|:--|:--|:--|
| Haptics | `QeetrixFeedback`, `.qeetrixFeedback(_:trigger:)` | — (iOS only) |
| Format | `QeetrixFormat` (numbers, currency, percent, sizes, durations, dates, times, ranges, relative time) | format |
| Relative time | `QeetrixRelativeTime` | RelativeTime |
| List item | `QeetrixListItem`, `QeetrixListItemIcon`, `.buttonStyle(.qeetrixListItem())`, `.qeetrixListStyle()` | — (iOS only) |
| Section header | `QeetrixSectionHeader` | — (iOS only) |
| Description list | `QeetrixDescriptionList`, `QeetrixDescriptionItem` | DescriptionList |
| Check list | `QeetrixCheckList`, `QeetrixCheckItem` | CheckList |
| Alert | `QeetrixAlert` | Alert |
| Empty and data state | `QeetrixEmptyState`, `QeetrixDataState` | EmptyState, DataState |
| Skeleton | `QeetrixSkeleton`, `.qeetrixSkeletonGroup(label:)` | Skeleton |
| Timeline | `QeetrixTimeline`, `QeetrixTimelineGroup`, `QeetrixTimelineItem` | Timeline |
| Steps | `QeetrixSteps`, `QeetrixStep` | Steps |
| Chip | `QeetrixChip`, `QeetrixChipGroup`, `.toggleStyle(.qeetrixChip())` | Chip, ChipGroup |
| Segmented control | `QeetrixSegmentedControl` | ToggleGroup (segmented) |
| Accordion | `QeetrixAccordion`, `QeetrixAccordionItem`, `.disclosureGroupStyle(.qeetrixAccordion())` | Accordion, Collapsible |
| Page indicator | `QeetrixPageIndicator` | — (iOS only) |
| Avatar group | `QeetrixAvatarGroup` | AvatarGroup |
| Circular progress | `QeetrixCircularProgress`, `.progressViewStyle(.qeetrixCircular())` | — (Progress's track and tones) |
| QR code | `QeetrixQRCode` | QRCode |
| QR scanner | `QeetrixQRScanner` | — (iOS only) |
| Permission primer | `QeetrixPermissionPrimer` | — (iOS only) |
| Bottom action bar | `.qeetrixBottomActionBar(primary:secondary:)`, `QeetrixScreenAction` | — (iOS only) |
| Full-screen form | `QeetrixFullScreenForm`, `.qeetrixFullScreenForm(isPresented:…)` | Dialog (`size="fullscreen"`) |
| Large title | `.qeetrixNavigationBar(background:title:)` | — (styles the system bar) |
| Sidebar and detail | `QeetrixSidebar`, `QeetrixNavigationScaffold`, `QeetrixNavigationItem` | Sidebar, AppShell |
| Search field | `QeetrixSearchField`, `.qeetrixSearchable(text:…)` | SearchField |
| Copy button and field | `QeetrixCopyButton`, `QeetrixCopyField` | CopyButton, CopyField |
| OTP code | `QeetrixOTPCode` | — (iOS and Android) |
| Swipe actions | `QeetrixSwipeAction`, `.qeetrixSwipeActions(…)` | — (iOS only) |
| Pull to refresh | `.qeetrixRefreshable(…)`, `QeetrixRefreshResult` | — (iOS only) |
| Date picker and range | `QeetrixDatePicker`, `QeetrixDateRangePicker`, `QeetrixCalendar`, `QeetrixRangeCalendar` | DatePicker, DateRangePicker, Calendar, RangeCalendar |
| Time picker | `QeetrixTimePicker` | — (iOS only) |
| Stat | `QeetrixStat`, `QeetrixStatGroup` | Stat, StatGroup |
| Slider | `QeetrixSlider` | Slider |
| Searchable picker | `QeetrixCombobox` | Combobox |
| Attachments | `QeetrixFileUpload`, `QeetrixFileRow`, `QeetrixFileLimits` | FileUpload |

Where SwiftUI has a style protocol, the style works on native controls too: `NavigationLink`,
`ShareLink`, `Toggle`, `ProgressView`.

API and usage documentation is in the DocC catalogue (`Sources/Qeetrix/Qeetrix.docc`): open the
package in Xcode and choose **Product › Build Documentation**, or run `Scripts/docs.sh`. Architecture,
decisions and standards are in [Documentation/](Documentation/).

Generated coverage, including what is deliberately not generated, is listed in
[Documentation/Foundations/TOKEN_COVERAGE.md](Documentation/Foundations/TOKEN_COVERAGE.md).

## Requirements

- iOS 17 or later.
- Swift 6 toolchain. Verified with Xcode 27.1 (Swift 6.4).

`Package.swift` also declares macOS 14. That is there only so `swift build` and `swift test` run on a
Mac during development; macOS is not a supported product platform.

## Install

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL. In a package
manifest:

```swift
.package(url: "https://github.com/qeetgroup/qeetrix-ios.git", branch: "main")
```

Then add `Qeetrix` to your target's dependencies. Nothing else is needed at build time; the package
does not need the web repositories.

## Use

```swift
import Qeetrix
import SwiftUI

@main
struct MyApp: App {
    // Same key and values as the web ThemeProvider's stored preference.
    @AppStorage("theme") private var mode: QeetrixThemeMode = .system

    init() {
        QeetrixFontRegistry.register()  // optional: surfaces a font problem at launch
    }

    var body: some Scene {
        WindowGroup {
            ContentView().qeetrixThemeMode(mode)
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            Text("Welcome back")
                .qeetrixTextStyle(.headingSm)
                .foregroundStyle(QeetrixColor.textDefault)
            Label {
                Text("Your account is protected").qeetrixTextStyle(.bodyMd)
            } icon: {
                QeetrixIcon(.lock, size: .sm, shape: .sharp)  // decorative: the text says what it means
            }
            .foregroundStyle(QeetrixColor.textSubtle)
        }
        .padding(QeetrixSpace.insetLg)
        .background(QeetrixColor.surfaceRaised, in: RoundedRectangle(cornerRadius: QeetrixRadius.surface))
        .overlay { RoundedRectangle(cornerRadius: QeetrixRadius.surface).strokeBorder(QeetrixColor.borderDefault) }
    }
}
```

Components are built from the same foundations:

```swift
QeetrixCard(title: Text("Two-step sign-in"), description: Text("A passkey on this device")) {
    QeetrixSwitch("Require a passkey", isOn: $requirePasskey)
} footer: {
    QeetrixButton("Save", size: .lg, isLoading: isSaving) { save() }
}
```

- **Colours** resolve from the view's colour scheme. Use `.qeetrixThemeMode(_:)` once, at the root;
  use `.qeetrixTheme(.dark)` to draw one part of a screen in a fixed theme. Where an API needs a
  `Color`, read `@Environment(\.qeetrixTheme) var theme` and call `theme.color(.borderDefault)`.
- **Typography** roles scale with Dynamic Type along a matching system text style, set the
  typeface's weight, letter-style (`GEOM`) and optical-size axes the way `@qeetrix/react` does, keep
  the role's line height on every line, and step one weight heavier when Bold Text is on.
- **Icons** are decorative unless you pass `label:`. They scale with Dynamic Type relative to `.body`
  (pass `relativeTo: nil` for a fixed size) and mirror in right-to-left layouts when their meaning
  has a direction.
- **Motion** through `.qeetrixAnimation(_:_:value:)` turns animation off when Reduce Motion is on.

## Build and test

```sh
swift build && swift test                       # library, on the Mac host
xcodebuild test -scheme Qeetrix \
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # library, on iOS
swift test --package-path Tools/QeetrixGen      # generator
Scripts/verify.sh                               # snapshot matches lock; generated files current
Scripts/lint.sh                                 # swift-format, strict
Scripts/api-check.sh                            # public API matches Documentation/API
Scripts/docs.sh                                 # DocC documentation, warnings as errors
Scripts/check.sh                                # all of the above that runs without a simulator, and more
```

Component snapshots and the showcase's UI tests run on the iOS Simulator. Snapshot baselines are
recorded on your machine and never committed (ADR 0013): record them on a commit you trust, then run
the snapshots on your change to compare.

```sh
TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all xcodebuild test -scheme Qeetrix -only-testing:QeetrixSnapshotTests \
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # record the baselines
xcodebuild test -scheme Qeetrix -only-testing:QeetrixSnapshotTests \
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # compare with them
xcodebuild test -project Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj -scheme QeetrixShowcase \
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # UI tests
```

The showcase app, `Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj`, shows every foundation and
component in both themes and at any text size, grouped as ui.qeet.in groups them. It depends on this
package through a local reference. Launch it with `-page switch` (any page's identifier) to open that
page, or `-page foundations -section icons` to open the foundations at a section.

To start a new component, run `Scripts/new-component.sh <Family> <Component> --category "<docs
category>"`; see [Templates/Component/README.md](Templates/Component/README.md).

## Updating from upstream

Tokens, fonts, icons and the component reference CSS are never edited here. Change them upstream,
publish to npm, then:

1. Bump the pin in `Upstream/pins.json` (`@qeetrix/tokens`, `@qeetrix/icons`, `@qeetrix/react`).
2. Run `Scripts/sync-upstream.sh`, which fetches from npm, verifies and re-locks.
3. Run `Scripts/generate.sh`, read the diff of `Upstream/qeetrix-react/css/` and of the generated files,
   then run the tests.

See [CONTRIBUTING.md](CONTRIBUTING.md#upstream-sync).

## Known limitations

- **Scope.** Thirty components and patterns, of `@qeetrix/react`'s 86 component families. 30 icons are
  included, and no logos. Some components are partial — the select has no multiple choice, tabs are
  horizontal only, the password field has no Caps Lock warning; the
  [migration notes](Documentation/MIGRATION_QEETRIX_REACT.md#components) list each gap.
- **System-drawn overlays.** Alerts, confirmation dialogs, sheets, popovers and menus are drawn by iOS:
  their material and font are the system's (ADR 0014). One toast shows at a time, and there is no
  separate centred dialog or inline alert yet.
- **Snapshots are local.** Baselines are not committed, so CI does not compare snapshots (ADR 0013).
- **Increased contrast.** `@qeetrix/tokens` defines no contrast context yet, so colours are the same
  under Increased Contrast. Every designed pair meets WCAG 2.2 AA in both schemes, and the tests check
  this.
- **Line height.** A role's line height applies to every line, with CSS half-leading; where a role's
  line is shorter than Qeet Sans's natural line, SwiftUI can't tighten the space between lines of
  wrapped text, so only the first and last lines take it exactly.
- **Sizes are the web's.** Body text is 14 pt, where iOS defaults to 17 pt, and the default density's
  controls are 28–40 pt high. Components keep the drawn size and extend their touch target to 44 pt
  without moving layout. Both choices are recorded for design review in
  [ARCHITECTURE.md](ARCHITECTURE.md#open-design-questions).
- **Component geometry is not a token.** Padding, gaps and corner details come from `@qeetrix/react`'s
  CSS, restated in each component; the drift check can't see a change to them, but a version bump
  shows the CSS diff in `Upstream/qeetrix-react/css/`.
- **Verification.** Simulator tests ran on iOS 27.1 (the iPhone Duo) and iOS 26.5 (iPhone SE, 16e, 17,
  Air, 17 Pro Max, iPad (A16), iPad mini). No iOS 17 runtime was available, so behaviour on iOS 17 is
  compiled against but not run. VoiceOver, Bold Text and Full Keyboard Access have been checked through
  their semantics in tests and UI tests, not by a person on a device.

## Licence

No licence has been chosen for this package's own code yet; choosing one is Qeet Group's decision. Bundled fonts and icon artwork carry their
own licences; see [Documentation/THIRD_PARTY_NOTICES.md](Documentation/THIRD_PARTY_NOTICES.md).
