# ``Qeetrix/QeetrixSlider``

## Overview

A number, or a range, on a continuous scale where the position matters more than the exact value — a
discount, a threshold — as `@qeetrix/react`'s Slider, as its own field. When the exact value matters,
use a ``QeetrixNumberField``.

```swift
QeetrixSlider("Discount", value: $discount, in: 0...50, step: 5, showsValue: true)
QeetrixSlider(
    "Budget", range: $budget, in: 0...100_000, step: 500, format: .currency("INR", fractionDigits: 0...0), showsBounds: true)
```

- **The header**: the label, in the field label's look, at the start; with `showsValue`, the value —
  or a range's two, joined by an en dash — in `label.sm` tabular figures, `color.text.default`, at the
  end, on the same baseline.
- **The control** (slider.css): a 4-point `color.border.default` track with square ends, filled
  `color.bg.brand.bold` from the minimum to the thumb, or between a range's two thumbs; each thumb a
  16-point square with 2-point corners in Ember, inside a 2-point `color.surface.default` ring so it
  reads on the fill, and `color.bg.brand.bold-hover` under a pointer or a finger.
- **Bounds**: `showsBounds` writes the minimum and the maximum under the track's ends, in `label.sm`,
  `color.text.subtle`.
- **Values** snap to `step` from the minimum and stay inside the bounds; a range's thumbs never cross.
  ``QeetrixSliderFormat`` writes them with ``QeetrixFormat``: numbers, a fraction as a percentage, money.
- **The field**: the description, or the error that replaces it, under the slider as in every field.
- **Disabled**: the fill `color.bg.disabled` and the thumbs `color.icon.disabled`; nothing moves.

```swift
QeetrixSlider(
    "Alert threshold", value: $threshold, in: 0...1, step: 0.05, format: .percent, showsValue: true,
    description: Text("Alert when usage passes this share of the quota."))
```

### Why Qeetrix draws it

SwiftUI's `Slider` takes a tint and nothing else: its round white thumb with a shadow, its rounded
track and its size are the system's, and it has no range. The web's look — the square Ember thumb with
its ring, the square-ended track — and a range need Qeetrix's own control. It keeps what the system
slider gives: each thumb is an adjustable element for VoiceOver, moves with the keyboard, and follows
the reading direction.

### Accessibility

- VoiceOver reads each thumb as adjustable, named by the label — a range's as "Budget, minimum" and
  "Budget, maximum" — with its value written by `format`; the description is its hint and the error is
  read with it. Swiping up or down moves it a step, or by `largeStep` (a tenth of the range by default)
  when the slider has more than 20 steps, as the system's slider moves.
- The control is 44 points tall and each thumb a 44-point target; a drag anywhere on the control moves
  the nearest thumb, and a tap moves it there.
- A hardware keyboard focuses each thumb, with the 2-point `color.border.focus` frame 2 points outside
  it: the arrows move a step (left and right mirrored in right-to-left layouts), Page Up and Page Down
  move `largeStep`, Home and End go to the ends.
- In right-to-left layouts the minimum is at the right and the fill grows leftwards.
- The track, `color.border.default`, is a rule under 3:1 on the surfaces, as on the web; the fill and the
  thumbs, at 3:1, show the control and its value.

### Platform differences

- **A 44-point control**, where the web's is 24 pixels (`size.target.min`): the touch target.
- **Bounds** under the track (`showsBounds`) are iOS's, as the system slider's minimum and maximum
  labels are; the web shows only the value.
- **No haptic per step**, as the system's slider has none: a fine slider dragged end to end would tick
  a hundred times.
- **Not carried**: a custom VoiceOver value (`getAriaValueText`) and `name`. `onEditingChanged` is
  called as a drag starts and ends — the web's `onValueCommitted`.

On the web: [Slider on ui.qeet.in](https://ui.qeet.in/components/slider/).

## Topics

### Formats

- ``QeetrixSliderFormat``
