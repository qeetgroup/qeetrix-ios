# Sizing

Size controls and rows with the Qeetrix densities.

## Overview

``QeetrixDensity`` defines four metrics at three densities, in points:

| Metric | ``QeetrixDensity/compact`` | ``QeetrixDensity/default`` | ``QeetrixDensity/comfortable`` |
|:--|--:|--:|--:|
| ``QeetrixDensity/controlHeight`` | 28 | 32 | 36 |
| ``QeetrixDensity/rowHeight`` | 40 | 40 | 52 |
| ``QeetrixDensity/cellPaddingY`` | 6 | 12 | 12 |
| ``QeetrixDensity/fieldGap`` | 8 | 16 | 16 |

Set a density for a view hierarchy with `.qeetrixDensity(_:)`, and read it with
`@Environment(\.qeetrixDensity)`:

```swift
struct SettingsRow: View {
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        Text("Notifications")
            .qeetrixTextStyle(.body)
            .frame(maxWidth: .infinity, minHeight: density.rowHeight, alignment: .leading)
    }
}
```

## Touch targets

Density heights are drawing sizes, taken from the web. A tappable element still needs a hit area of at
least 44 × 44 points; `.qeetrixMinimumTouchTarget()` provides one without changing the drawing. See
<doc:Accessibility>.

Icon sizes are in ``QeetrixIconSize``; see <doc:Icons>.
