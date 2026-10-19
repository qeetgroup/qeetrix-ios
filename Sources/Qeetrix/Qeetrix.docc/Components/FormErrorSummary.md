# ``Qeetrix/QeetrixFormErrorSummary``

## Overview

After a failed submit, the errors of a long form in one place — the web's `FormErrorSummary`. Each field
still shows its own message; the summary adds the overview. A short form with one or two fields
doesn't need it.

```swift
QeetrixFormErrorSummary(errors: [
    .init(id: "email", message: "Enter a valid email address.") { focus = .email }
])
```

- Each error is a link: tapping it runs its action, which should move focus to the field it is about.
- It draws nothing while there are no errors.
- The heading is "There is a problem" unless you give one.

### Accessibility

When errors appear or change, VoiceOver announces the heading and the errors, as the web's
`role="alert"` does. Each error is a full 44 pt row, so neighbouring links never share a target.

On the web: [Form on ui.qeet.in](https://ui.qeet.in/docs/components/form).

## Topics

### Errors

- ``QeetrixFormErrorSummary/Item``
