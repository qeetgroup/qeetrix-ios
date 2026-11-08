# ``Qeetrix/QeetrixCircularProgress``

## Overview

A value as a ring — the seconds left on a one-time code, an upload beside its file name — the circular
counterpart of ``QeetrixProgress``. `@qeetrix/react` has no circular progress, so the ring takes the
bar's track and tones, and the spinner's sizes and 2-point line.

```swift
HStack(spacing: QeetrixSpace.gapLg) {
    QeetrixCircularProgress(value: 0.4, label: Text("Uploading invoice.pdf"))
    QeetrixCircularProgress(value: 1, size: .lg, tone: .success, label: Text("Upload complete"))
}
```

- **Ring**: a 2-point line (spinner.css's) of the progress track — `color.border.default` in light,
  `color.surface.sunken` in dark — with square ends, as the bar has.
- **Indicator**: from twelve o'clock clockwise to `value`, in the tone's colour: `color.bg.brand.bold`
  while it runs (`brand`), `color.bg.success.bold` once done (`success`), `color.bg.danger.bold` if it
  failed (`danger`), and for `warning` — nearly out — `color.border.warning` in light and
  `color.bg.warning.bold` in dark: progress.css's `--qx-progress-warning`, which Meter's warning uses.
  Every tone keeps 3:1 against the track in both schemes; the bold amber would be 1.5:1 in light.
- **Size**: `sm` 14, `md` 16 (default), `lg` 20 or `xl` 24 points — the icon sizes, by
  ``QeetrixSpinner``'s names. It grows with Dynamic Type, as an icon does, and its line with it.
- `value` is a fraction of `total` (1 by default). A new value moves over `motion.duration.normal`, eased
  `standard`, as the bar's does.

### A countdown

`timerInterval` makes the ring follow the clock itself, so it moves smoothly without the app redrawing it.
Give the tone and the words VoiceOver reads from a view that updates once a second — here a one-time
code, which turns `warning` in its last five seconds:

```swift
TimelineView(.periodic(from: period.lowerBound, by: 1)) { context in
    let secondsLeft = Int(period.upperBound.timeIntervalSince(context.date).rounded(.up))
    QeetrixCircularProgress(
        timerInterval: period, size: .lg, tone: secondsLeft <= 5 ? .warning : .brand,
        label: Text("Time left on this code"), currentValueLabel: Text("\(secondsLeft) seconds left"))
}
```

With `countsDown` on (the default) the ring empties as the interval runs out; off, it fills.

### Styling any progress view

``QeetrixCircularProgressViewStyle`` gives any `ProgressView` the ring. A `ProgressView` without a value
shows the spinner's turning ring in the tone's colour.

```swift
ProgressView(value: 0.25)
    .progressViewStyle(.qeetrixCircular(size: .lg, tone: .success))
```

### Accessibility

- VoiceOver reads it as the system's progress indicator: the `label`, then `currentValueLabel` as its
  value ("12 seconds left"). Without one it reads the percentage — or, for a timer, the time left in
  words for the locale ("12 seconds"). A timer ring is marked as updating frequently.
- Colour never carries the meaning alone: say "seconds left" in the value, and next to a code show the
  count as text where there's room.
- Under Reduce Motion a new value jumps instead of moving, and a timer ring steps once a second, on the
  interval's whole seconds.

### Platform differences

- `@qeetrix/react` has no ring: this is iOS's, built from the bar's track and tones (progress.css) and the
  spinner's line and sizes (spinner.css). The warning tone is the Meter's.
- It reads like a clock face, so it turns clockwise in right to left too, where the bar fills from the
  right.
- `timerInterval` and `countsDown` are SwiftUI's own `ProgressView(timerInterval:countsDown:)`
  parameters; the web has no timer form.

On the web: [Progress on ui.qeet.in](https://ui.qeet.in/components/progress/), the bar this ring is the
circular form of.

## Topics

### Styling

- ``QeetrixCircularProgressSize``
- ``QeetrixCircularProgressTone``
- ``QeetrixCircularProgressViewStyle``
