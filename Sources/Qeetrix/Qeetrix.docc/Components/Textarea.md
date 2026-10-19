# ``Qeetrix/QeetrixTextarea``

## Overview

Multi-line plain text: feedback, notes, descriptions. For a single line use ``QeetrixTextField``; for
formatted text a rich-text editor, which Qeetrix for iOS does not provide.

```swift
QeetrixTextarea(
    "Feedback", text: $feedback,
    prompt: Text("What could be better?"),
    description: Text("Up to 500 characters.")
)
```

- **Size.** Two control heights to start, growing with the text to 15 lines — the web's 24 rem cap —
  then scrolling, so a long note never pushes the rest of a form off the screen.
- **Prompt.** Drawn while the field is empty; never part of the value.
- **States.** A message colours the boundary; `isReadOnly` shows the text selectable with a dashed
  boundary; `disabled(_:)` shows the sunken surface and fades it.

### Keyboard and accessibility

Return starts a new line, so a textarea does not submit a form. Selection, the edit menu and dictation
work as in any iOS text field. VoiceOver reads a text field named by the label, with the description as
its hint and the message attached.

### Platform differences

The web textarea can be resized by dragging its corner; on iOS it grows with its text instead.

On the web: [Textarea on ui.qeet.in](https://ui.qeet.in/docs/components/textarea).

## See Also

- ``QeetrixTextField``
- ``QeetrixField``
