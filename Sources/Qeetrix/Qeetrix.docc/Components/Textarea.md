# ``Qeetrix/QeetrixTextarea``

## Overview

Multi-line text with its label, help text and error — `@qeetrix/react`'s Textarea in a Field. For one
line, use ``QeetrixTextField``.

```swift
QeetrixTextarea("Notes", text: $notes, prompt: Text("e.g. Deliver after 5 pm"), rows: 4)
```

- The same box as ``QeetrixTextField``, `rows` lines tall at least (3 by default), with the vertical
  padding that centres one line in an input's height.
- It grows with its content up to `maxRows`, then scrolls; without `maxRows` it keeps growing.
- The same focus, invalid, read-only and disabled states as a text field.

### Accessibility

VoiceOver reads it by its label, with its value, description and error, as a text field.

### Platform differences

The web textarea can be dragged taller where `field-sizing` isn't supported; on iOS it always grows
with its text.

On the web: [Textarea on ui.qeet.in](https://ui.qeet.in/components/textarea/).
