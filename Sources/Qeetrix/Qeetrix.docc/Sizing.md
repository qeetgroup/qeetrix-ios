# Sizing

Size controls and rows with the Qeetrix densities.

## Overview

``QeetrixDensity`` is `@qeetrix/tokens`' density modifier: three densities that share one set of
components (design rules §6). Each sets the control heights, the row height and the form gap, in
points:

| Size | ``QeetrixDensity/compact`` | ``QeetrixDensity/default`` | ``QeetrixDensity/comfortable`` |
|:--|--:|--:|--:|
| ``QeetrixDensity/sizeControlSm`` | 24 | 28 | 32 |
| ``QeetrixDensity/sizeControlMd`` | 28 | 32 | 36 |
| ``QeetrixDensity/sizeControlLg`` | 32 | 40 | 44 |
| ``QeetrixDensity/sizeRow`` | 32 | 40 | 48 |
| ``QeetrixDensity/spaceFormGap`` | 12 | 16 | 20 |

Use `compact` for data-heavy consoles, `default` for most screens and `comfortable` for welcoming
pages such as sign-in and checkout. Set a density once per region, never per component, with
`.qeetrixDensity(_:)`, and read it with `@Environment(\.qeetrixDensity)`:

```swift
struct SettingsRow: View {
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        Text("Notifications")
            .qeetrixTextStyle(.bodyMd)
            .frame(maxWidth: .infinity, minHeight: density.sizeRow, alignment: .leading)
    }
}
```

## Control sizes

``QeetrixControlSize`` — `sm`, `md`, `lg`, `@qeetrix/react`'s `ControlSize` — picks a control's height
from the density: ``QeetrixDensity/controlHeight(_:)``. Buttons are `md` by default; fields are always
`lg`, and a form's main button is `lg` too, so it lines up with its fields.

## Touch targets

Density heights are drawing sizes, taken from the web. Every tappable Qeetrix component still has a hit
area of at least 44 × 44 points, without changing its drawing; `.qeetrixMinimumTouchTarget()` does the
same for your own controls. See <doc:Accessibility>.

``QeetrixSize/targetMin`` (24 points) is the web's minimum pointer target; the smallest an OTP slot
shrinks to. Icon sizes are in ``QeetrixIconSize``; see <doc:Icons>.
