# Theming

Draw in the Qeetrix light and dark themes, follow the system, and fix a theme for part of a screen.

## Overview

Qeetrix has two themes, light and dark, and one brand. A view's theme comes from its SwiftUI colour
scheme, so it follows the device setting, the app's choice and any override above it, and changes
live. There is no global theme object.

## Choose the app's theme

``QeetrixThemeMode`` has the web's three modes: `light`, `dark` and `system`. Apply one at the root
with `.qeetrixThemeMode(_:)`. It sets the window's colour scheme, so system UI such as sheets,
alerts, the status bar and the keyboard matches. `.system` follows the device.

## Use semantic colours

``QeetrixColor`` is a `ShapeStyle`. Use it wherever SwiftUI accepts one, and it resolves to the right
value for the view's theme:

```swift
Text("Payment received")
    .foregroundStyle(QeetrixColor.textSuccess)
    .padding(QeetrixSpacing.m)
    .background(QeetrixColor.feedbackSuccessSubtle, in: RoundedRectangle(cornerRadius: QeetrixCorner.chip))
```

Colours are named for their role (`textPrimary`, `surfaceElevated`, `borderControl`), not for their
hue. Raw palette values are deliberately not available. Pair text and backgrounds by role: those
pairs meet WCAG 2.2 AA contrast in both themes.

Where an API takes a `Color` rather than a `ShapeStyle`, read the theme from the environment:

```swift
struct HairlineRule: View {
    @Environment(\.qeetrixTheme) private var theme

    var body: some View {
        Rectangle()
            .fill(theme.color(.borderDefault))
            .frame(height: QeetrixStroke.hairline)
    }
}
```

## Fix a theme for part of a screen

`.qeetrixTheme(_:)` draws a subtree in one theme, whatever the app's. Use it for previews and
side-by-side specimens:

```swift
HStack {
    Palette().qeetrixTheme(.light)
    Palette().qeetrixTheme(.dark)
}
```

## Increased contrast

``QeetrixTheme/contrast`` reports the user's Increased Contrast setting. Qeetrix does not define
separate high-contrast values yet, so colours are the same under both settings. The standard values
already meet AA contrast.
