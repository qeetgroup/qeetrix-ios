# Shapes

Round corners, draw borders and focus rings with the Qeetrix shape tokens.

## Corners

``QeetrixCorner`` gives corner radii by purpose:

- ``QeetrixCorner/control`` and ``QeetrixCorner/field``: buttons and inputs.
- ``QeetrixCorner/chip``: chips, badges and small swatches.
- ``QeetrixCorner/surface``: cards and panels.
- ``QeetrixCorner/overlay``: dialogs and other modal overlays.
- ``QeetrixCorner/pill``: a capsule.

For a circle, use `Circle()`.

```swift
RoundedRectangle(cornerRadius: QeetrixCorner.surface)
    .fill(QeetrixColor.surfaceElevated)
```

## Strokes

``QeetrixStroke`` gives border widths: ``QeetrixStroke/hairline`` (1 point), ``QeetrixStroke/thin``
(2) and ``QeetrixStroke/thick`` (3). Draw borders in a `border*` colour:

```swift
RoundedRectangle(cornerRadius: QeetrixCorner.control)
    .stroke(QeetrixColor.borderControl, lineWidth: QeetrixStroke.hairline)
```

## Focus rings

``QeetrixFocus`` gives the focus-ring geometry: ``QeetrixFocus/ringWidth``,
``QeetrixFocus/outlineWidth`` and ``QeetrixFocus/offset``. The ring's colour is
``QeetrixColor/focusRing``.
