# Shadows

Lift floating layers off the page with the Qeetrix shadows — and only floating layers.

## Overview

Qeetrix surfaces are flat. Everything in the page flow — cards, panels, tables — is separated by tone
and 1-point lines, never by shadows; only layers that float over the page have one (design rules §12).
``QeetrixShadow`` gives `@qeetrix/tokens`' shadows, each with its own light and dark layers:

- ``QeetrixShadow/overlay``: menus, popovers, select lists and toasts.
- ``QeetrixShadow/modal``: dialogs and drawers.
- ``QeetrixShadow/raised`` and ``QeetrixShadow/raisedHover``: a floating surface at rest and under a
  pointer.
- ``QeetrixShadow/inset``: a recessed well.

Draw a floating surface with `.qeetrixShadow(_:fill:in:)`. It paints the shadow, the fill, and any inset
highlight behind the view:

```swift
Text("Saved to your library")
    .qeetrixTextStyle(.bodyMd)
    .padding(QeetrixSpace.insetLg)
    .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
```

The shadows are drawn the way the web draws its box shadows, including spread, the 1-point outline ring
of the raised, overlay and modal shadows, and the inset top highlight of the dark scheme's overlay and modal shadows.
``QeetrixShadow/layers(for:)`` returns the individual layers if you need them.
