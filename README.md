# Qeetrix for iOS

The native SwiftUI implementation of **Qeetrix**, the Qeet Group design system. It gives iOS apps the
same tokens, typeface, themes and icons as the web's [`@qeetrix/ui`](https://github.com/qeetgroup/qeetrix-ui)
and [`@qeetrix/icons`](https://github.com/qeetgroup/qeetrix-icons), generated from those packages
rather than copied from them.

**Status: Phase 7 — release candidate 0.1.0-rc.1, prepared and not released.** No version is tagged
yet; see [the candidate report](Documentation/Releases/RELEASE_CANDIDATE_REPORT.md). The foundations (tokens, theming,
typography, icons, accessibility helpers), the core components, the form controls and patterns, navigation
and overlays, and list rows, details, accordions, chips, timelines and the empty, loading and failure
states, each with tests, a DocC page and a showcase page ([PHASES.md](PHASES.md)). Every component is
**Beta**: tested and audited by machine, not yet checked on a device or released — see
[the maturity matrix](Documentation/Quality/COMPONENT_MATURITY_MATRIX.md) and
[the release-readiness gaps](Documentation/Quality/RELEASE_READINESS_GAPS.md).

## What is in it

| Area | API | Source |
|:--|:--|:--|
| Colour | `QeetrixColor` — 84 semantic colours, a `ShapeStyle` that resolves light/dark from the environment | `@qeetrix/ui` consumable `color.*` |
| Theme | `QeetrixThemeMode` (`light` / `dark` / `system`), `.qeetrixThemeMode(_:)`, `.qeetrixTheme(_:)`, `@Environment(\.qeetrixTheme)` | `ThemeProvider` modes |
| Typography | `QeetrixTextRole` (9 roles), `.qeetrixTextStyle(_:)`, `QeetrixFontRegistry` | `typography.*`, Qeet Sans (Cal Sans VF) and Fira Code |
| Spacing, size, shape | `QeetrixSpacing`, `QeetrixCorner`, `QeetrixStroke`, `QeetrixFocus`, `QeetrixDensity`, `QeetrixOpacity` | `space`, `corner`, `stroke.width`, `focus`, `density`, `state` |
| Elevation | `QeetrixElevation`, `.qeetrixElevation(_:fill:in:)` | `elevation.*` (per theme) |
| Motion | `QeetrixDuration`, `QeetrixEasing`, `QeetrixMotion`, `.qeetrixAnimation(_:_:value:)` | `motion.*` |
| Icons | `QeetrixIcon`, `QeetrixIconName` (37 icons), `Image(qeetrix:)` for system chrome | `qeetrix-icons` SVGs |
| Accessibility | `QeetrixAccessibility.minimumTouchTarget`, `.qeetrixMinimumTouchTarget()`, `contrastRatio(_:on:)` | Apple HIG, WCAG 2.2 |

### Components

| Component | API | On the web |
|:--|:--|:--|
| Text | `QeetrixText` (`h1`–`h4`, `p`, `lead`, `large`, `small`, `muted`, `blockquote`, `inlineCode`) | Typography |
| Separator | `QeetrixSeparator` | Separator |
| Card | `QeetrixCard`, `QeetrixCardHeader`, `.buttonStyle(.qeetrixCard())` | Card |
| Badge | `QeetrixBadge` | Badge |
| Button | `QeetrixButton`, `.buttonStyle(.qeetrix())` | Button |
| Icon button | `QeetrixIconButton` | Icon Button |
| Spinner | `QeetrixSpinner` | Spinner |
| Progress | `QeetrixProgress`, `.progressViewStyle(.qeetrix())` | Progress |
| Avatar | `QeetrixAvatar` | Avatar |
| Switch | `QeetrixSwitch`, `.toggleStyle(.qeetrixSwitch())` | Switch |
| Text field | `QeetrixTextField`, `QeetrixFieldMessage` | Input and Field |
| Field | `QeetrixField`, `QeetrixFieldSet` | Field |
| Textarea | `QeetrixTextarea` | Textarea |
| Password input | `QeetrixPasswordInput` | Password Input |
| OTP input | `QeetrixOTPInput` | OTP Input |
| Checkbox | `QeetrixCheckbox`, `.toggleStyle(.qeetrixCheckbox)` | Checkbox |
| Radio group | `QeetrixRadioGroup`, `QeetrixOption` | Radio Group |
| Select | `QeetrixSelect`, `QeetrixOption` | Select, Native Select |
| Number field | `QeetrixNumberField` | Number Field |
| Form | `QeetrixFormActions`, `QeetrixFormErrorSummary` | Form |
| Tabs | `QeetrixTabs`, `QeetrixTab` | Tabs |
| Navigation and tab bars | `.qeetrixNavigationBar(background:)`, `.qeetrixTabBar()`, `.qeetrixTabItem(_:icon:badge:)` | — (styles the system bars) |
| Alert dialog | `QeetrixAlertDialog`, `.qeetrixAlertDialog(_:)`, `QeetrixDialogAction` | Alert Dialog |
| Confirmation dialog | `QeetrixConfirmationDialog`, `.qeetrixConfirmationDialog(_:)` | — (iOS action sheet) |
| Sheet | `.qeetrixSheet(isPresented:…)`, `.qeetrixSheet(item:…)`, `QeetrixSheetContent` | Drawer, Dialog |
| Popover | `.qeetrixPopover(isPresented:…)` | Popover |
| Menu | `QeetrixMenu`, `QeetrixMenuItem` | Dropdown Menu, Context Menu |
| Toast | `QeetrixToast`, `.qeetrixToast(_:)` | Toast |
| List item | `QeetrixListItem`, `QeetrixListItemIcon`, `.qeetrixListRow()`, `.buttonStyle(.qeetrixListItem)`, `QeetrixSectionHeader` | — (iOS list rows) |
| Description list | `QeetrixDescriptionList`, `QeetrixDescriptionItem` | Description List |
| Accordion | `QeetrixAccordion`, `QeetrixAccordionItem`, `.disclosureGroupStyle(.qeetrix)` | Accordion, Collapsible |
| Empty state | `QeetrixEmptyState` | Empty State |
| Data state | `QeetrixDataState`, `QeetrixDataFailure`, `QeetrixDataLoadingRows` | Data State |
| Skeleton | `QeetrixSkeleton`, `QeetrixSkeletonText` | Skeleton |
| Chip | `QeetrixChip`, `QeetrixChipGroup` | Chip |
| Timeline | `QeetrixTimeline`, `QeetrixTimelineItem` | Timeline |
| Search | native `.searchable` with `QeetrixEmptyState` and `QeetrixChipGroup` | — |

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
manifest, once a version is tagged:

```swift
// Before 1.0 a minor version may break source, so take patches only.
.package(url: "https://github.com/qeetgroup/qeetrix-ios.git", .upToNextMinor(from: "0.1.0"))
```

Then add the `Qeetrix` product to your target. Nothing else is needed at build time: no web
repositories, Node.js or generator. Until the first tag, only a branch or revision can be used, for
evaluation. Versions, requirements and access to the private repository:
[Documentation/Releases/DISTRIBUTION.md](Documentation/Releases/DISTRIBUTION.md).

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
        VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
            Text("Welcome back")
                .qeetrixTextStyle(.title)
                .foregroundStyle(QeetrixColor.textPrimary)
            Label {
                Text("Your account is protected").qeetrixTextStyle(.body)
            } icon: {
                QeetrixIcon(.lock, variant: .filled)  // decorative: the text says what it means
            }
            .foregroundStyle(QeetrixColor.textSecondary)
        }
        .padding(QeetrixSpacing.l)
        .qeetrixElevation(.raised, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
    }
}
```

Components are built from the same foundations:

```swift
QeetrixCard {
    QeetrixCardHeader("Two-step sign-in", description: "A passkey on this device")
    QeetrixSwitch("Require a passkey", isOn: $requirePasskey)
} footer: {
    QeetrixButton("Save", isLoading: isSaving) { save() }
}
```

- **Colours** resolve from the view's colour scheme. Use `.qeetrixThemeMode(_:)` once, at the root;
  use `.qeetrixTheme(.dark)` to draw one part of a screen in a fixed theme. Where an API needs a
  `Color`, read `@Environment(\.qeetrixTheme) var theme` and call `theme.color(.borderDefault)`.
- **Typography** roles scale with Dynamic Type along a matching system text style, set the
  typeface's weight, letter-style (`GEOM`) and optical-size axes the way the web does, and step one
  weight heavier when Bold Text is on.
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
Scripts/api-compat.sh origin/main               # no source-breaking change against main
Scripts/consumer-check.sh                       # an independent app installs the package by version
Scripts/release-check.sh 0.1.0-rc.1             # every release gate, with evidence (publishes nothing)
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
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # UI tests and the accessibility audit
```

The UI tests include `AccessibilityAuditUITests`, Apple's accessibility audit over every showcase page,
which fails on any issue it doesn't exclude with a reason. Quality reports — accessibility,
localization, performance, security and privacy, API compatibility, test coverage — are in
[Documentation/Quality](Documentation/Quality/PHASE_6_AUDIT.md).

The showcase app, `Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj`, shows every foundation and
component in both themes and at any text size, grouped as ui.qeet.in groups them. It depends on this
package through a local reference. Launch it with `-page switch` (any page's identifier) to open that
page, or `-page foundations -section icons` to open the foundations at a section.

To start a new component, run `Scripts/new-component.sh <Family> <Component> --category "<docs
category>"`; see [Templates/Component/README.md](Templates/Component/README.md).

## Updating from upstream

Tokens, fonts and icons are never edited here. Change them upstream, then:

1. Bump the pin in `Upstream/pins.json`.
2. Run `Scripts/sync-upstream.sh`, which fetches, verifies and re-locks.
3. Run `Scripts/generate.sh`, then the tests.

See [CONTRIBUTING.md](CONTRIBUTING.md#upstream-sync).

## Known limitations

- **Scope.** Forty components and patterns. Component tokens are generated for the thirteen groups they
  use (accordion, avatar, badge, button, card, dialog, input, popover, progress, skeleton, switch,
  timeline, typography) of the 41 upstream defines. 37 icons are included, and no logos. There is no
  data table or image component (ADR 0015).
- **System-drawn overlays.** Alerts, confirmation dialogs and menus are drawn by iOS: only the tint is
  Qeetrix's. One toast shows at a time, and there is no snackbar, separate centred dialog or inline alert
  yet (ADR 0014).
- **Snapshots are local.** Baselines are not committed, so CI does not compare snapshots (ADR 0013).
  The snapshot host measures at the default text size and draws at AX3, so components that reflow at
  the accessibility sizes overlap in their AX3 images; UI tests check that reflow in the app instead.
- **Built-in strings are English.** The library's 19 strings ("Loading", "Required", "Close"…) have no
  translations yet, so a localised app hears them in English
  ([localization report](Documentation/Quality/LOCALIZATION_REPORT.md)).
- **Increased contrast.** Qeetrix defines no contrast theme yet, so colours are the same under
  Increased Contrast. Every semantic text pair already meets WCAG 2.2 AA in both themes, and the
  tests check this.
- **Line height.** SwiftUI cannot set lines tighter than a font's natural height, so a role's line
  height is a minimum. Unlike CSS, there is no half-leading above the first line.
- **Sizes are the web's.** Body text is 14 pt, where iOS defaults to 17 pt, and control densities are
  28–36 pt high. Components keep the drawn size and extend their touch target to 44 pt without moving
  layout. Both choices are recorded for design review in
  [ARCHITECTURE.md](ARCHITECTURE.md#open-design-questions).
- **Component geometry is not a token.** Heights, padding and type steps come from Tailwind utility
  classes on the web, restated once in the package (ADR 0011); the drift check cannot see a change to
  them.
- **Verification.** Simulator tests ran on iOS 27.1 only, on the one device type that runtime offers.
  No iOS 17 runtime was available, so behaviour on iOS 17 itself is compiled against but not yet run.
  No iPad simulator was available either: regular-width behaviour (popovers, form sheets) was checked
  through an iPhone in landscape.
  VoiceOver, Bold Text and Full Keyboard Access have been checked through their semantics in tests and
  UI tests, not by a person on a device.

## Licence

No licence has been chosen for this package's own code yet. `@qeetrix/ui` is published as
`UNLICENSED`, and choosing one is Qeet Group's decision. Bundled fonts and icon artwork carry their
own licences; see [Documentation/THIRD_PARTY_NOTICES.md](Documentation/THIRD_PARTY_NOTICES.md).
