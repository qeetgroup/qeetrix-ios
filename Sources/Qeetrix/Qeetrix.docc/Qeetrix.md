# ``Qeetrix``

The Qeet Group design system in native SwiftUI: the same tokens, typeface, themes and icons as the web.

## Overview

Qeetrix for iOS is generated from the same sources as the web: the published `@qeetrix/ui` token build
and the `qeetrix-icons` drawings. Colours, type, spacing, elevation, motion and icons therefore match
Qeetrix on the web, adapted to iOS where the platform needs it: Dynamic Type, Bold Text, Reduce Motion,
right-to-left layout and 44-point touch targets.

It provides the foundations and the first components, built from them. Each component follows its web
counterpart's variants, sizes and states, and adapts to the platform where iOS needs it; its page says
where and why.

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

### Actions

- ``QeetrixButton``
- ``QeetrixIconButton``

### Forms & inputs

- <doc:Forms>
- ``QeetrixField``
- ``QeetrixFieldSet``
- ``QeetrixTextField``
- ``QeetrixTextarea``
- ``QeetrixPasswordInput``
- ``QeetrixOTPInput``
- ``QeetrixCheckbox``
- ``QeetrixRadioGroup``
- ``QeetrixSelect``
- ``QeetrixNumberField``
- ``QeetrixSwitch``
- ``QeetrixFormActions``
- ``QeetrixFormErrorSummary``

### Data display

- ``QeetrixAvatar``
- ``QeetrixBadge``
- ``QeetrixText``

### Feedback

- ``QeetrixToast``
- ``QeetrixProgress``
- ``QeetrixSpinner``

### Overlays

- <doc:Overlays>
- ``QeetrixAlertDialog``
- ``QeetrixConfirmationDialog``
- ``QeetrixSheetContent``
- <doc:Popover>
- ``QeetrixMenu``

### Navigation

- ``QeetrixTabs``
- <doc:NavigationBars>

### Layout

- ``QeetrixCard``
- ``QeetrixSeparator``

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
