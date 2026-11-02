# Shapes

Corners, borders and the focus frame — Qeetrix is square.

## Corners

Qeetrix is square (design rules §3): 4-point corners on controls and surfaces, 2 points on small marks,
and soft shapes only for people and status. ``QeetrixRadius`` gives the radii by purpose:

| Radius | Points | Use |
|:--|--:|:--|
| ``QeetrixRadius/control``, ``QeetrixRadius/surface``, ``QeetrixRadius/overlay``, ``QeetrixRadius/modal`` | 4 | Buttons, fields (top corners only), cards, menus, popovers, toasts, dialogs |
| ``QeetrixRadius/sm``, ``QeetrixRadius/tooltip`` | 2 | Checkboxes, the switch track, keyboard keys |
| ``QeetrixRadius/none`` | 0 | Tables, tab lists, dividers |
| ``QeetrixRadius/chip``, ``QeetrixRadius/full`` | pill | Status badges (`chip`), avatars and radios (`full`) — use `Capsule()` or `Circle()` |

Never mix corner sizes within one component, and never round a corner that meets a ruled edge.

```swift
RoundedRectangle(cornerRadius: QeetrixRadius.surface)
    .fill(QeetrixColor.surfaceRaised)
```

## Borders

``QeetrixBorderWidth`` gives the line widths: `default` (1 point), ``QeetrixBorderWidth/strong`` (2)
and ``QeetrixBorderWidth/accent`` (3) — the Ember bar that marks the current item and the intent line
on top of a dialog. Draw lines in a `border*` colour:

```swift
RoundedRectangle(cornerRadius: QeetrixRadius.control)
    .stroke(QeetrixColor.borderStrong, lineWidth: QeetrixBorderWidth.default)
```

## The focus frame

Keyboard focus is one frame everywhere (design rules §10): 2 points of Ember
(``QeetrixFocus/ringWidth``, ``QeetrixColor/borderFocus``) — inside a button, with a 1-point surface
gap; inside a field, replacing its bottom line; 2 points outside checkboxes, radios, switches and
selectable cards (``QeetrixFocus/ringOffset``); inside a tab. Qeetrix components draw it when they have
keyboard focus.
