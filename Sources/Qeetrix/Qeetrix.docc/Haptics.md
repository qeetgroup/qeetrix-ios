# Haptics

Tap the same way for the same moment in every Qeetrix app, and stay silent when the person asks.

## Overview

``QeetrixFeedback`` names five moments and plays the platform's haptic for each:

| Role | When | Plays |
|:--|:--|:--|
| ``QeetrixFeedback/selection`` | A choice changed: a switch, checkbox or radio, a tab, a picker's value | the selection tick |
| ``QeetrixFeedback/success`` | A task finished as asked: saved, sent, refreshed | the success notification |
| ``QeetrixFeedback/warning`` | A task finished but needs attention: saved offline, a limit nearly reached | the warning notification |
| ``QeetrixFeedback/error`` | A task failed: a rejected code, a declined payment, a form that can't be sent | the error notification |
| ``QeetrixFeedback/lightImpact`` | A small, physical confirmation: a copy; a swipe or a pull crossing the point where letting go acts; a drag snapping into place | a light impact |

Choose by what happened, not by how it should feel. Each role is SwiftUI's `SensoryFeedback` for that
moment (``QeetrixFeedback/sensoryFeedback``), and the same UIKit generator when played directly.

## Play feedback when a value changes

`.qeetrixFeedback(_:trigger:)` plays a role each time its trigger changes — build it on the value the
person's action changes, so a value the app sets itself (loading saved settings, a sync) doesn't tap:

```swift
Button("Copy invoice number") {
    copy(invoiceNumber)
    copies += 1
}
.qeetrixFeedback(.lightImpact, trigger: copies)
```

A condition limits it to some changes, and a closure can choose the role — for an outcome that can go
either way:

```swift
Color.clear
    .qeetrixFeedback(.lightImpact, trigger: isPastThreshold) { _, isPast in isPast }
    .qeetrixFeedback(trigger: submission) { _, result in
        switch result {
        case .sent: .success
        case .rejected: .error
        case nil: nil
        }
    }
```

For code that isn't a view — a completion handler, a UIKit delegate — ``QeetrixFeedback/play()``
plays a role at once, on the main actor:

```swift
QeetrixFeedback.error.play()
```

## In Qeetrix's own components

- ``QeetrixSwitch``, ``QeetrixCheckbox`` and ``QeetrixRadioGroup`` play ``QeetrixFeedback/selection``
  when a person changes them — by touch, or through VoiceOver, Switch Control or Full Keyboard Access.
  A change the app makes to the binding plays nothing, and neither does choosing the radio already
  chosen.
- Copy (``QeetrixCopyButton``, ``QeetrixOTPCode``) plays ``QeetrixFeedback/lightImpact`` once the
  text is on the pasteboard, as Android does.
- Swipe actions and pull to refresh are the system's, and the system plays their haptics as the swipe
  opens and the pull crosses its threshold; Qeetrix adds ``QeetrixFeedback/success`` or
  ``QeetrixFeedback/error`` when a refresh finishes (<doc:PullToRefresh>).
- Where a system control already answers a gesture with a haptic, Qeetrix doesn't add a second one.
  Check on a device before adding a role to a system gesture.

## When nothing plays

The system plays nothing when the person has turned System Haptics off (Settings › Sounds & Haptics),
while the app isn't in the foreground, on a device without a Taptic Engine — every iPad — and on the
Mac. Qeetrix adds no setting of its own: the system's is the one people know. So feedback
is never the only sign that something happened: the switch moves, Copy says "Copied", an error has its
message.

## Platform differences

`@qeetrix/react` has no haptics — a browser has no reliable way to play them — and neither has
`qeetrix-android` yet. The roles are iOS's own, named after the system's feedback types, so an Android
version can map them to `HapticFeedbackConstants` by the same names.

## Topics

### Roles

- ``QeetrixFeedback``
