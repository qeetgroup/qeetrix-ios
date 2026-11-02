# Theming

Draw in the Qeetrix light and dark colour schemes, follow the system, and fix a scheme for part of a
screen.

## Overview

Qeetrix has two colour schemes, light and dark — `@qeetrix/tokens`' `colorScheme` modifier — and one
brand. A view's scheme comes from its SwiftUI colour scheme, so it follows the device setting, the
app's choice and any override above it, and changes live. There is no global theme object.

## Choose the app's scheme

``QeetrixThemeMode`` has the web's three colour schemes: `light`, `dark` and `system`. Apply one at the
root with `.qeetrixThemeMode(_:)`. It sets the window's colour scheme, so system UI such as sheets,
alerts, the status bar and the keyboard matches. `.system` follows the device.

## Use semantic colours

``QeetrixColor`` is a `ShapeStyle`. Use it wherever SwiftUI accepts one, and it resolves to the right
value for the view's scheme:

```swift
Text("Payment received")
    .foregroundStyle(QeetrixColor.textSuccess)
    .padding(QeetrixSpace.insetMd)
    .background(QeetrixColor.bgSuccessSubtle, in: RoundedRectangle(cornerRadius: QeetrixRadius.control))
```

Colours are named for their role — `surfaceRaised`, `bgNeutralSubtle`, `textSubtle`, `borderStrong`,
`iconBrand` — never for their hue, and raw palette values are deliberately not available. Where each
may appear is a design rule (design rules §4):

- **Ember** (`bgBrandBold`, `borderBrand`, `textBrand`) only for the primary action, focus, the current
  item, checked controls and links — never for large surfaces, decoration or status.
- **Ember tint** (`bgBrandSubtle`, `bgSelected`) for selected rows and a ghost button's press.
- **Warm graphite** (`bgNeutralBold`) for the secondary action.
- **Neutral tints** (`bgNeutralSubtle` and its `Hover` and `Pressed` steps) for field fills and pressed
  backgrounds.
- **Status colours** (`danger`, `warning`, `success`, `info`) for status only, always with a word or an
  icon.
- The page is `surfaceCanvas`; content sits on `surfaceRaised`.

The pairs the tokens are designed for meet WCAG 2.2 AA contrast in both schemes.

Where an API takes a `Color` rather than a `ShapeStyle`, read the theme from the environment:

```swift
struct HairlineRule: View {
    @Environment(\.qeetrixTheme) private var theme

    var body: some View {
        Rectangle()
            .fill(theme.color(.borderDefault))
            .frame(height: QeetrixBorderWidth.default)
    }
}
```

## Fix a scheme for part of a screen

`.qeetrixTheme(_:)` draws a subtree in one scheme, whatever the app's — the counterpart of a
`data-qx-color-scheme` attribute on a section. Use it for previews and side-by-side specimens:

```swift
HStack {
    Palette().qeetrixTheme(.light)
    Palette().qeetrixTheme(.dark)
}
```

## Increased contrast

``QeetrixTheme/contrast`` reports the user's Increased Contrast setting. `@qeetrix/tokens` has no
contrast context yet, so colours are the same under both settings; the standard values already meet AA
contrast.
