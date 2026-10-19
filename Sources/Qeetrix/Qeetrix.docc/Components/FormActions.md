# ``Qeetrix/QeetrixFormActions``

## Overview

A form's buttons, placed the way the web's `FormActions` places them.

```swift
QeetrixFormActions {
    QeetrixButton("Cancel", variant: .outline) { dismiss() }
    QeetrixButton("Create account", isLoading: isSubmitting) { submit() }
}
```

List the buttons in reading order, primary last. On a compact-width screen they stack full-width with the
primary on top, where a thumb reaches it first; in a regular-width size class they sit in a row at the
trailing edge, wrapping when the row is full. Show a submission in progress with the button's own
`isLoading`.

On the web: [Form on ui.qeet.in](https://ui.qeet.in/docs/components/form).

## See Also

- ``QeetrixFormErrorSummary``
- <doc:Forms>
