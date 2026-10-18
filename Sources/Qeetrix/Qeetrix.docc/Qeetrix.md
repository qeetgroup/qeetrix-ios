# ``Qeetrix``

The Qeet Group design system in native SwiftUI: the same tokens, typeface, themes and icons as the web.

## Overview

Qeetrix for iOS is generated from the same sources as the web: the published `@qeetrix/ui` token build
and the `qeetrix-icons` drawings. Colours, type, spacing, elevation, motion and icons therefore match
Qeetrix on the web, adapted to iOS where the platform needs it: Dynamic Type, Bold Text, Reduce Motion,
right-to-left layout and 44-point touch targets.

This release provides the foundations. Components come in later phases and are built from these same
foundations.

```swift
import Qeetrix
import SwiftUI

struct Greeting: View {
    var body: some View {
        Text("Welcome back")
            .qeetrixTextStyle(.title)
            .foregroundStyle(QeetrixColor.textPrimary)
            .padding(QeetrixSpacing.l)
    }
}
```

## Topics

### Essentials

- <doc:GettingStarted>

### Foundations

- <doc:Theming>
- <doc:Typography>
- <doc:Spacing>
- <doc:Shapes>
- <doc:Sizing>
- <doc:Elevation>
- <doc:Motion>
- <doc:Icons>
- <doc:Accessibility>

### Theme

- ``QeetrixThemeMode``
- ``QeetrixTheme``

### Colour

- ``QeetrixColor``

### Typography

- ``QeetrixTextRole``
- ``QeetrixTextRoleTokens``
- ``QeetrixTextMetrics``
- ``QeetrixFontRegistry``
- ``QeetrixFontFamily``
- ``QeetrixFontFace``
- ``QeetrixFontAxis``
- ``QeetrixFontWeight``
- ``QeetrixFontGeometry``

### Spacing, shape and size

- ``QeetrixSpacing``
- ``QeetrixCorner``
- ``QeetrixStroke``
- ``QeetrixFocus``
- ``QeetrixDensity``
- ``QeetrixOpacity``

### Elevation

- ``QeetrixElevation``
- ``QeetrixShadowLayer``

### Motion

- ``QeetrixMotion``
- ``QeetrixDuration``
- ``QeetrixEasing``

### Icons

- ``QeetrixIcon``
- ``QeetrixIconName``
- ``QeetrixIconShape``
- ``QeetrixIconVariant``
- ``QeetrixIconSize``
- ``QeetrixIconStroke``

### Accessibility

- ``QeetrixAccessibility``

### Provenance

- ``QeetrixProvenance``
