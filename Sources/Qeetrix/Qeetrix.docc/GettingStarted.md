# Getting started

Add Qeetrix to an app, set its theme, and draw your first view with Qeetrix foundations and
components.

## Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter the repository URL, and add the `Qeetrix`
library to your app target. In a package manifest, take a version and its patches:

```swift
.package(url: "https://github.com/qeetgroup/qeetrix-ios.git", .upToNextMinor(from: "0.3.0"))
```

Qeetrix requires iOS 17 and has no dependencies of its own. <doc:Installing> covers versions
and requirements.

## Set the theme once, at the root

Apply ``QeetrixThemeMode`` with `.qeetrixThemeMode(_:)` near the root of each scene. Its values —
`light`, `dark` and `system` — are `@qeetrix/react`'s colour schemes, so a stored preference reads the
same on both.

Read the stored preference in the scene's root view, not in the `App`: a `WindowGroup`'s content isn't
rebuilt when the `App`'s own state changes, so a choice made while the app runs wouldn't reach the window.

```swift
import Qeetrix
import SwiftUI

@main
struct ExampleApp: App {
    init() {
        // Optional: loads the bundled fonts now, so a problem is logged at launch.
        QeetrixFontRegistry.register()
    }

    var body: some Scene {
        WindowGroup { RootView() }
    }
}

struct RootView: View {
    @AppStorage("theme") private var mode: QeetrixThemeMode = .system

    var body: some View {
        ContentView()
            .qeetrixThemeMode(mode)
    }
}
```

## Build with foundations

Colours, type, spacing and corners all come from Qeetrix rather than literals. Page content sits on
raised surfaces, separated by tone and 1-point lines — never by shadows (design rules §12). This is the
surface ``QeetrixCard`` draws for you:

```swift
struct AccountCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            Text("Your account")
                .qeetrixTextStyle(.titleSm)
                .foregroundStyle(QeetrixColor.textDefault)
            HStack(spacing: QeetrixSpace.gapXs) {
                QeetrixIcon(.lock, size: .sm, shape: .sharp)
                Text("Two-step verification is on").qeetrixTextStyle(.bodyMd)
            }
            .foregroundStyle(QeetrixColor.textSubtle)
        }
        .padding(QeetrixSpace.insetLg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QeetrixColor.surfaceRaised, in: RoundedRectangle(cornerRadius: QeetrixRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: QeetrixRadius.surface)
                .strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixBorderWidth.default)
        }
    }
}
```

## Where the values come from

Every value is generated from pinned npm releases, never typed in by hand.
``QeetrixProvenance/bundled()`` reports the exact versions inside your build:

```swift
let provenance = try QeetrixProvenance.bundled()
print(provenance.tokens.version)      // for example "0.0.15"
print(provenance.components.version)  // the @qeetrix/react release the components follow
```
