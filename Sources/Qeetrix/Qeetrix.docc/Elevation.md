# Elevation

Lift surfaces off the page with the Qeetrix shadows.

## Overview

``QeetrixElevation`` levels match the web's shadows, and each has its own light and dark values:

- ``QeetrixElevation/flat``: no shadow.
- ``QeetrixElevation/subtle`` and ``QeetrixElevation/low``: a slight lift.
- ``QeetrixElevation/raised``: cards.
- ``QeetrixElevation/hover``: a card under the pointer.
- ``QeetrixElevation/overlay``: menus and popovers.
- ``QeetrixElevation/modal``: dialogs and sheets.
- ``QeetrixElevation/inset``: a recessed surface.
- `ramp2xs` to `rampXl`: the underlying shadow ramp.

Draw a surface with `.qeetrixElevation(_:fill:in:)`. It paints the shadow, the fill, and any inset
highlight behind the view:

```swift
Text("Saved to your library")
    .qeetrixTextStyle(.body)
    .padding(QeetrixSpacing.l)
    .qeetrixElevation(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixCorner.overlay))
```

The shadows are drawn the way the web draws its box shadows, including:

- spread;
- the 1-point outline ring of raised surfaces;
- the top highlight that dark overlays carry.

``QeetrixElevation/layers(for:)`` returns the individual layers if you need them.
