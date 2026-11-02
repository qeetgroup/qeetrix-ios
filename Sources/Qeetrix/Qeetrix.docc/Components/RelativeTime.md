# ``Qeetrix/QeetrixRelativeTime``

## Overview

When something happened, as people say it — `@qeetrix/react`'s RelativeTime (07-components.md, C3):
"2 minutes ago", "yesterday", "in 3 days", then the date once it's further away than the threshold.

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
    QeetrixRelativeTime(invoice.sentAt)
    QeetrixRelativeTime(device.lastSeen, size: .sm, tone: .subtle)
}
```

- **Text**: ``QeetrixFormat/relativeTime(_:now:locale:)`` — the largest whole unit, rounded first, so
  59 minutes 40 seconds is "1 hour ago" — in the environment's locale.
- **Past the threshold** (30 days by default, either way): the date with its month abbreviated, "10
  Sept 2026" in `en-IN`, in the environment's time zone.
- **Live**: it refreshes while it's on screen — every 15 seconds within a minute of the moment, every
  minute within an hour, then every 30 minutes, the web's cadence. `isLive: false` keeps the text it
  first showed; `now:` fixes the clock, for previews, tests and screenshots, and stops the updates.
- **Type**: body text, as ``QeetrixText`` sets it, with its `size`, `weight` and `tone`, in tabular
  figures (`relative-time.css`), so a column of times doesn't shift as they change.

```swift
QeetrixRelativeTime(invoice.sentAt, threshold: .seconds(7 * 86_400), now: previewNow)
```

### Accessibility

VoiceOver reads the text, with the full date and time as its hint — "25 October 2026 at 2:30 pm" —
which a pointer shows as a tooltip. It scales with Dynamic Type and Bold Text through the body role,
and wraps at the largest sizes rather than truncating. Nothing moves, so Reduce Motion has nothing to
change; in right-to-left layouts the text follows its language.

### Platform differences

- **The clock is a `TimelineView`**, on the web's cadence, rather than an interval timer: SwiftUI stops
  it off screen and slows it in the always-on display's low-frequency mode.
- **Its own type.** The web's RelativeTime inherits the surrounding font. SwiftUI text inherits no
  font from the paragraph around it, so this takes ``QeetrixText``'s `size`, `weight` and `tone`.
- **It wraps.** The web keeps it on one line (`white-space: nowrap`); at the accessibility text sizes
  iOS lets it wrap rather than run off the screen.
- **Locale and time zone** come from the environment (`\.locale`, `\.timeZone`), where the web reads
  QeetrixProvider's locale and the browser's zone. The date past the threshold and the full date are
  Gregorian, as the rest of Qeetrix's dates are; the web's RelativeTime leaves the calendar to the
  locale.
- **No machine-readable moment.** The web renders a `<time datetime>`; iOS has no equivalent, and the
  hint carries the exact date and time instead.

On the web: `RelativeTime` from `@qeetrix/react/experimental` — ui.qeet.in has no page for it yet.
