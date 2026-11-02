# ``Qeetrix/QeetrixProgress``

## Overview

A task advancing — an upload, an import — as `@qeetrix/react`'s Progress.

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
    QeetrixProgress("Uploading invoices", value: 0.4, showsValue: true)
    QeetrixProgress("Import failed", value: 0.62, tone: .danger)
    QeetrixProgress("Preparing export", value: nil)
}
```

- **Header**: the label in the field-label style (`label.sm`, `color.text.subtle`) and, with
  `showsValue`, the percentage (`label.sm`, tabular figures, `color.text.default`) at its end.
- **Track**: 4 points of `color.border.default` in light and `color.surface.sunken` in dark (so each
  tone keeps 3:1 against it), square ends. The indicator is `color.bg.brand.bold`
  while the task runs (`brand`), `color.bg.success.bold` once it's done (`success`) and
  `color.bg.danger.bold` if it failed (`danger`). It moves over `motion.duration.normal`.
- **Indeterminate** (`value: nil`): a 30%-wide segment slides along the track every 1.6 seconds.
- `value` is a fraction of `total` (1 by default).

``QeetrixProgressViewStyle`` styles any `ProgressView` the same way:

```swift
ProgressView("Syncing", value: 0.25)
    .progressViewStyle(.qeetrix(tone: .success))
```

### Accessibility

VoiceOver reads it as the system's progress indicator, with its label and percentage — or, while the
total isn't known, as an activity indicator. Under Reduce Motion the indeterminate segment spans the
track and fades instead of sliding, so the wait stays visible.

### Platform differences

The web's Progress takes `min`, `max` and a `format`; iOS takes `value` and `total`, as `ProgressView`
does, and formats a percentage for the environment's locale. The web's Meter, a measurement within a
range, has no iOS counterpart yet.

On the web: [Progress on ui.qeet.in](https://ui.qeet.in/components/progress/).

## Topics

### Styling

- ``QeetrixProgressTone``
- ``QeetrixProgressViewStyle``
