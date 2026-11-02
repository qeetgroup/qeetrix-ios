# ``Qeetrix/QeetrixTimeline``

## Overview

What happened, newest first — a person's sign-in activity, the critical events of an audit trail — as
`@qeetrix/react`'s Timeline.

```swift
QeetrixTimeline {
    QeetrixTimelineGroup("Today") {
        QeetrixTimelineItem(
            "Signed in with a passkey", description: "Bengaluru · Safari on iPhone", time: Text("2 min ago"), icon: .keyRound)
        QeetrixTimelineItem(
            "Sign-in refused", description: "Unknown device", time: Text("1 h ago"), icon: .circleX, tone: .danger)
    }
    QeetrixTimelineGroup("Yesterday") {
        QeetrixTimelineItem("Phone linked", time: Text("18:02"), icon: .smartphone, tone: .success)
    }
}
```

- **Events** (``QeetrixTimelineItem``): what happened (the title, `body.md` at weight 500), where, by
  whom or how (the description, `body.sm`, `color.text.subtle`) and when (the time, `body.sm`,
  `color.text.subtle`, at the end on one line). Pass the time formatted — `Text("2 min ago")`, or
  `Text(date, style: .relative)`.
- **Markers**: a 28-point square (`component.timeline.marker-size`) of `color.bg.neutral.subtle` with
  a 1-point `color.border.subtle` edge and 4-point corners, holding the event's sharp 16-point icon. A
  1-point `color.border.subtle` line runs from 4 points under it to 4 points above the next event.
- **Tone**: `neutral` (the default), `brand`, `info`, `success`, `warning` or `danger` colours the
  icon (`color.icon.<tone>`); `danger`, for a failure such as a refused sign-in, colours the title too.
- **Groups** (``QeetrixTimelineGroup``), such as one per day: a label in `label.caps`,
  `color.text.subtle`, 8 points above its events. Groups are 12 points apart, and the line breaks
  between them.
- **Compact**: `variant: .compact` draws minor events — a side panel, a short summary — with a 6-point
  dot centred on the title's first line and no line; events are 8 points apart, and titles take the
  regular weight.

```swift
QeetrixTimeline(variant: .compact) {
    QeetrixTimelineItem("Approved on iPhone", time: Text("2 min ago"), tone: .success)
    QeetrixTimelineItem("Approval requested", time: Text("3 min ago"))
}
```

The events, their order, their wording and their times are the app's. The full audit log stays a
list; a timeline is the short summary on a detail screen.

### Accessibility

- VoiceOver reads each event as one element — title, description, time — and the marker not at all:
  the title says what happened, so the tone is a second channel, never the only one.
- At the accessibility text sizes the time moves under the description, and the marker grows with its
  icon; where the title's line outgrows the marker, the marker moves down to its centre.
- In right-to-left layouts the markers and the line move to the right.

### Platform differences

- **Times** are `Text`, so an app can pass a date that updates itself (`Text(date, style: .relative)`);
  the web takes a node and a machine-readable `dateTime`.
- **Long histories.** The line joins the events of one timeline. For a long or growing history in a
  lazy list, use list rows instead.

On the web: [Timeline on ui.qeet.in](https://ui.qeet.in/components/timeline/).

## Topics

### Parts

- ``QeetrixTimelineItem``
- ``QeetrixTimelineGroup``

### Variants and tones

- ``QeetrixTimelineVariant``
- ``QeetrixTimelineTone``
