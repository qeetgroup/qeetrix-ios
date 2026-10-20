# ``Qeetrix/QeetrixTimeline``

## Overview

A vertical history of events — activity on a document, the life of an invoice.

```swift
QeetrixTimeline {
    QeetrixTimelineItem("Invoice paid", time: Text("09:41"), tone: .success, icon: .check)
    QeetrixTimelineItem("Reminder sent", time: Text("Yesterday"), tone: .info)
    QeetrixTimelineItem("Synced", emphasis: .minor)
}
```

- **Three levels.** A `minor` event is a small neutral dot with a muted title; a default event a toned
  dot; an event with an `icon` a tinted marker — for the few that matter most.
- **Tone** is a second channel: the title says what happened.
- **Rhythm.** Markers sit on a 24 pt rail joined by a connector; events are 24 pt apart, minor ones 12.
- **Times** sit at the end of the title line, and move below it at the accessibility sizes.

Your app orders, words, times and fetches the events; the timeline classifies nothing. It lays out in a
`ScrollView`, a card or a sheet — in a `List` the connectors can't join across rows.

### Accessibility

Each event is one element: title, time, description. When a marker conveys something the text doesn't,
pass `label` ("Failed") and VoiceOver reads it as the event's value.

On the web: [Timeline on ui.qeet.in](https://ui.qeet.in/docs/components/timeline).

## Topics

### Events

- ``QeetrixTimelineItem``
- ``QeetrixTimelineTone``
- ``QeetrixTimelineEmphasis``
