# Getting started

Add Qeetrix to an app, set its theme, and draw your first view with Qeetrix foundations.

## Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter the repository URL, and add the `Qeetrix`
library to your app target. In a package manifest, take a version and its patches:

```swift
.package(url: "https://github.com/qeetgroup/qeetrix-ios.git", .upToNextMinor(from: "0.1.0"))
```

Qeetrix requires iOS 17 and has no dependencies of its own. <doc:Installing> covers versions,
requirements and access to the private repository.

## Set the theme once, at the root

Apply ``QeetrixThemeMode`` with `.qeetrixThemeMode(_:)` near the root of each scene. Storing the
choice under the key `"theme"` uses the same key and values as the web's `ThemeProvider`.

```swift
import Qeetrix
import SwiftUI

@main
struct ExampleApp: App {
    @AppStorage("theme") private var mode: QeetrixThemeMode = .system

    init() {
        // Optional: loads the bundled fonts now, so a problem is logged at launch.
        QeetrixFontRegistry.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .qeetrixThemeMode(mode)
        }
    }
}
```

## Build with foundations

Colours, type, spacing and elevation all come from Qeetrix rather than literals:

```swift
struct AccountCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
            Text("Your account")
                .qeetrixTextStyle(.heading)
                .foregroundStyle(QeetrixColor.textPrimary)
            HStack(spacing: QeetrixSpacing.xs) {
                QeetrixIcon(.lock, size: .sm, variant: .filled)
                Text("Two-step verification is on").qeetrixTextStyle(.body)
            }
            .foregroundStyle(QeetrixColor.textSecondary)
        }
        .padding(QeetrixSpacing.l)
        .qeetrixElevation(.raised, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
    }
}
```

## Where the values come from

Every value is generated from a pinned `@qeetrix/ui` release, never typed in by hand.
``QeetrixProvenance/bundled()`` reports the exact versions inside your build:

```swift
let provenance = try QeetrixProvenance.bundled()
print(provenance.tokens.version)  // for example "2.1.6"
```
