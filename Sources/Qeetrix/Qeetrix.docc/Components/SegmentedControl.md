# ``Qeetrix/QeetrixSegmentedControl``

## Overview

One choice among a few that applies at once — `@qeetrix/react`'s ToggleGroup with
`variant="segmented"`: a filter (All, Pending) or a short setting (Light, Dark, System).

```swift
@State private var filter = Filter.all

QeetrixSegmentedControl(
    "Show", selection: $filter,
    options: [
        QeetrixOption("All", value: Filter.all),
        QeetrixOption("Pending", value: Filter.pending),
    ])
```

- **Look**: one joined control — a 1-point `color.border.strong` edge with 4-point corners round it, and
  the same rule between the segments, square at the joins.
- **Segments**: `label.md` in `color.text.subtle`, 12 points either side (8 at `sm`, 16 at `lg`). The
  chosen one is the warm graphite of the secondary button, `color.bg.neutral.bold`, with
  `color.text.inverse`. Pointer hover gives `color.bg.neutral.subtle` with `color.text.default`.
- **Size**: `sm`, `md` (default) or `lg`, at the controls' heights for the density in effect.
- **Disabled**: `disabled(_:)` dims every segment's text; an option with `isDisabled` can't be chosen.

One segment is always chosen. Use it for two to five short labels; more options want a
``QeetrixSelect``, panels of content ``QeetrixTabs``, and a choice in a form that's submitted a
``QeetrixRadioGroup``.

```swift
QeetrixSegmentedControl(
    "Theme", selection: $scheme,
    options: [
        QeetrixOption("Light", value: Scheme.light),
        QeetrixOption("Dark", value: Scheme.dark),
        QeetrixOption("System", value: Scheme.system),
    ],
    size: .sm)
```

### Accessibility

The label names the control for VoiceOver and isn't shown. Each segment is a button that is selected or
not, with its option's description as the hint, and VoiceOver says "selected" when one is chosen. Every
segment is at least 44 points wide, and its target extends to 44 points tall without moving layout.
Labels scale with Dynamic Type and Bold Text and, at the largest sizes, wrap rather than truncate; every
segment stays as tall as the tallest. Colour changes take `motion.duration.fast`, none under Reduce
Motion. Right to left, the first option is on the right. Keyboard focus is the Ember frame inside the
segment, with the surface-coloured gap.

### Platform differences

- **Qeetrix's own control, not `Picker(.segmented)`.** `Picker` with the segmented style is drawn by
  the system's `UISegmentedControl`: SwiftUI has no picker style an app can write, and the control can
  only be restyled through app-wide appearance settings, which can't give it the web's square, ruled
  segments, its graphite selection without a floating thumb, or Qeet Sans with Dynamic Type. Built
  from buttons that carry the selected trait — the pattern of ``QeetrixTabs`` and the radio group,
  checked by the showcase's UI tests — it reaches the web's look and keeps everything VoiceOver needs:
  a named group, each choice a button, the selection read and announced.
- **One is always chosen.** The web's ToggleGroup lets a pressed toggle be released, leaving nothing
  pressed; a segmented control for a filter or a setting always has a value, as the web's ThemeSwitcher
  does.
- **Touch.** A held touch shows the hover tint; the web has no pressed state.
- **Icons.** The web's toggles can show icons; this control shows labels only.
- **Width.** Each segment is at least 44 points wide; the web's can be narrower.

On the web: [Toggle group on ui.qeet.in](https://ui.qeet.in/components/toggle-group/).
