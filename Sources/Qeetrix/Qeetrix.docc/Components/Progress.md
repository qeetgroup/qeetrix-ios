# ``Qeetrix/QeetrixProgress``

## Overview

Task progress: a bar, with an optional label and percentage above it.

```swift
VStack(alignment: .leading, spacing: QeetrixSpacing.l) {
    QeetrixProgress("Uploading", value: 0.4)
    QeetrixProgress("Preparing export", value: nil)
}
```

- **Determinate.** The bar eases to each new value over the slow duration.
- **Indeterminate.** Pass `nil` while the total is unknown: a segment sweeps along the track, mirrored
  in right-to-left layouts.
- **Sizes.** `sm`, `md` and `lg` tracks are 4, 8 and 12 pt — fixed steps, not density-resolved.

``QeetrixProgressViewStyle`` gives any `ProgressView` the same bar:

```swift
ProgressView("Syncing", value: 0.25)
    .progressViewStyle(.qeetrix(size: .sm))
```

### Accessibility

- VoiceOver reads a native progress indicator: the label, then the percentage. While the total is
  unknown it reads an activity indicator with the label, and no percentage.
- A bar without a label needs `accessibilityLabel(_:)`.
- With Reduce Motion on, an indeterminate bar is a still, hatched fill — busy, not done.

### Platform adaptations

The percentage is formatted for the person's locale (for example "40 %" in French), as the web formats
it with the browser's locale.

On the web: [Progress on ui.qeet.in](https://ui.qeet.in/docs/components/progress).

## Topics

### Styling

- ``QeetrixProgressSize``
- ``QeetrixProgressViewStyle``
