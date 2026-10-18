# Qeetrix for iOS

The native SwiftUI implementation of **Qeetrix**, the Qeet Group design system. It gives iOS apps the
same tokens, typeface, themes and icons as the web's [`@qeetrix/ui`](https://github.com/qeetgroup/qeetrix-ui)
and [`@qeetrix/icons`](https://github.com/qeetgroup/qeetrix-icons), generated from those packages
rather than copied from them.

**Status: Phase 1 — foundations.** Tokens, theming, typography, icon infrastructure and accessibility
helpers. There are no components yet; they start in Phase 2 ([PHASES.md](PHASES.md)).

## What is in it

| Area | API | Source |
|:--|:--|:--|
| Colour | `QeetrixColor` — 84 semantic colours, a `ShapeStyle` that resolves light/dark from the environment | `@qeetrix/ui` consumable `color.*` |
| Theme | `QeetrixThemeMode` (`light` / `dark` / `system`), `.qeetrixThemeMode(_:)`, `.qeetrixTheme(_:)`, `@Environment(\.qeetrixTheme)` | `ThemeProvider` modes |
| Typography | `QeetrixTextRole` (9 roles), `.qeetrixTextStyle(_:)`, `QeetrixFontRegistry` | `typography.*`, Qeet Sans (Cal Sans VF) and Fira Code |
| Spacing, size, shape | `QeetrixSpacing`, `QeetrixCorner`, `QeetrixStroke`, `QeetrixFocus`, `QeetrixDensity`, `QeetrixOpacity` | `space`, `corner`, `stroke.width`, `focus`, `density`, `state` |
| Elevation | `QeetrixElevation`, `.qeetrixElevation(_:fill:in:)` | `elevation.*` (per theme) |
| Motion | `QeetrixDuration`, `QeetrixEasing`, `QeetrixMotion`, `.qeetrixAnimation(_:_:value:)` | `motion.*` |
| Icons | `QeetrixIcon`, `QeetrixIconName` (12 icons in Phase 1) | `qeetrix-icons` SVGs |
| Accessibility | `QeetrixAccessibility.minimumTouchTarget`, `.qeetrixMinimumTouchTarget()`, `contrastRatio(_:on:)` | Apple HIG, WCAG 2.2 |

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
Scripts/docs.sh                                 # DocC documentation, warnings as errors
```

The showcase app, `Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj`, shows every foundation in
both themes and at any text size. It depends on this package through a local reference. Launch it
with `-section icons` (or `colours`, `typography`, `spacing`, `elevation`) to open at a section.

## Updating from upstream

Tokens, fonts and icons are never edited here. Change them upstream, then:

1. Bump the pin in `Upstream/pins.json`.
2. Run `Scripts/sync-upstream.sh`, which fetches, verifies and re-locks.
3. Run `Scripts/generate.sh`, then the tests.

See [CONTRIBUTING.md](CONTRIBUTING.md#upstream-sync).

## Known limitations

- **Phase 1 scope.** There are no components, the 216 component tokens are not generated, and only 12
  icons are included. Logos are not included.
- **Increased contrast.** Qeetrix defines no contrast theme yet, so colours are the same under
  Increased Contrast. Every semantic text pair already meets WCAG 2.2 AA in both themes, and the
  tests check this.
- **Line height.** SwiftUI cannot set lines tighter than a font's natural height, so a role's line
  height is a minimum. Unlike CSS, there is no half-leading above the first line.
- **Sizes are the web's.** Body text is 14 pt, where iOS defaults to 17 pt, and control densities are
  28–36 pt high, below the 44 pt touch target. Both are recorded for design review in
  [ARCHITECTURE.md](ARCHITECTURE.md#open-design-questions).
- **Verification.** Simulator tests ran on iOS 27.1 only. No iOS 17 runtime was available, so behaviour
  on iOS 17 itself is compiled against but not yet run. VoiceOver and Bold Text have not been checked
  on a device.

## Licence

No licence has been chosen for this package's own code yet. `@qeetrix/ui` is published as
`UNLICENSED`, and choosing one is Qeet Group's decision. Bundled fonts and icon artwork carry their
own licences; see [Documentation/THIRD_PARTY_NOTICES.md](Documentation/THIRD_PARTY_NOTICES.md).
