# ``Qeetrix``

The Qeet Group design system in native SwiftUI: the same tokens, typeface, icons and components as
`@qeetrix/react`.

## Overview

Qeetrix for iOS is built from the same npm packages as the web: `@qeetrix/tokens` (the DTCG token
build and the fonts), `@qeetrix/icons` (the drawings) and `@qeetrix/react` (the components, whose CSS
is each component's reference). Colours, type, spacing, corners, shadows, motion, icons and components
therefore match Qeetrix on the web — square, ruled surfaces, filled fields with a strong bottom line,
label-first buttons, Ember only where it means something — and adapt to iOS where the platform needs
it: Dynamic Type, Bold Text, Reduce Motion, VoiceOver, right-to-left layout, 44-point touch targets,
and the system's own alerts, sheets, popovers and menus.

Each component follows its `@qeetrix/react` counterpart's names, variants, tones, sizes and states; its
page links to the web documentation and says where iOS differs, and why.

```swift
import Qeetrix
import SwiftUI

struct Greeting: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            QeetrixHeading("Welcome back", level: 1)
            QeetrixText("Your invoices are up to date.", tone: .subtle)
        }
        .padding(QeetrixSpace.insetLg)
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
- <doc:Shadows>
- <doc:Motion>
- <doc:Haptics>
- <doc:Icons>
- <doc:Accessibility>

### Layout

- ``QeetrixCard``
- ``QeetrixSeparator``

### Type

- ``QeetrixHeading``
- ``QeetrixText``

### Actions

- ``QeetrixButton``
- ``QeetrixIconButton``
- ``QeetrixSegmentedControl``
- <doc:BottomActionBar>
- ``QeetrixCopyButton``

### Forms & inputs

- <doc:Forms>
- ``QeetrixField``
- ``QeetrixFieldset``
- ``QeetrixTextField``
- ``QeetrixSearchField``
- ``QeetrixTextarea``
- ``QeetrixPasswordInput``
- ``QeetrixOTPInput``
- ``QeetrixNumberField``
- ``QeetrixSlider``
- ``QeetrixSelect``
- ``QeetrixCombobox``
- ``QeetrixCheckbox``
- ``QeetrixRadioGroup``
- ``QeetrixSwitch``
- ``QeetrixFormActions``
- ``QeetrixErrorSummary``
- ``QeetrixQRScanner``
- ``QeetrixCopyField``
- ``QeetrixFileUpload``

### Date & time

- ``QeetrixDatePicker``
- ``QeetrixDateRangePicker``
- ``QeetrixTimePicker``
- ``QeetrixCalendar``
- ``QeetrixRangeCalendar``

### Overlays

- <doc:Overlays>
- ``QeetrixAlertDialog``
- ``QeetrixConfirmationDialog``
- ``QeetrixSheetContent``
- ``QeetrixFullScreenForm``
- <doc:Popover>
- ``QeetrixMenu``
- ``QeetrixToast``

### Navigation

- ``QeetrixTabs``
- <doc:NavigationBars>
- ``QeetrixAccordion``
- ``QeetrixPageIndicator``
- <doc:LargeTitle>
- ``QeetrixSidebar``
- ``QeetrixNavigationScaffold``
- ``QeetrixSteps``

### Data display

- ``QeetrixAvatar``
- ``QeetrixBadge``
- ``QeetrixChip``
- ``QeetrixAvatarGroup``
- ``QeetrixTimeline``
- ``QeetrixRelativeTime``
- ``QeetrixQRCode``
- ``QeetrixDescriptionList``
- ``QeetrixListItem``
- ``QeetrixSectionHeader``
- ``QeetrixOTPCode``
- ``QeetrixSwipeAction``
- <doc:PullToRefresh>
- ``QeetrixStat``

### Feedback

- ``QeetrixProgress``
- ``QeetrixSpinner``
- ``QeetrixAlert``
- ``QeetrixEmptyState``
- ``QeetrixDataState``
- ``QeetrixSkeleton``

### Utilities

- ``QeetrixFormat``
- ``QeetrixCircularProgress``
- ``QeetrixPermissionPrimer``
- ``QeetrixCheckList``

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

### Space, shape and size

- ``QeetrixSpace``
- ``QeetrixRadius``
- ``QeetrixBorderWidth``
- ``QeetrixFocus``
- ``QeetrixSize``
- ``QeetrixDensity``
- ``QeetrixControlSize``
- ``QeetrixOpacity``

### Shadows

- ``QeetrixShadow``
- ``QeetrixShadowLayer``

### Motion

- ``QeetrixMotion``
- ``QeetrixDuration``
- ``QeetrixEasing``
- ``QeetrixSpring``

### Haptics

- ``QeetrixFeedback``

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
