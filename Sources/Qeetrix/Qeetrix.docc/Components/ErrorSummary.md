# ``Qeetrix/QeetrixErrorSummary``

## Overview

What to fix before a form can be submitted — `@qeetrix/react`'s ErrorSummary (GOV.UK's error summary):
the danger Alert at the top of the form, titled "Fix these to continue", with one link per problem.

```swift
QeetrixErrorSummary(items: [
    .init(id: "email", message: "Enter a work email") { focus = .email },
    .init(id: "pan", message: "Enter the PAN as 10 characters") { focus = .pan },
])
```

- **When.** Show it after a submit that fails validation, or when server errors arrive; remove it once
  a submit succeeds.
- **Items** are worded exactly as the fields' own errors, in the order of the fields. Each link's
  action should scroll to its field and focus it.
- **Look** (alert.css): `color.bg.danger.subtle` with a 3-point `color.icon.danger` edge on the start
  side, a sharp 16-point alert icon, the title in `label.md` at weight 600, and the links in
  `color.text.link`, underlined.

### Accessibility

When it appears or changes, VoiceOver announces the title and every problem — the web's `role="alert"`.
The title is a heading of `headingLevel` (2 by default). Each link is a full 44-point row, so
neighbouring targets never overlap.

### Platform differences

- **Focus.** The web moves focus to the summary when it appears; on iOS the announcement takes its
  place, and VoiceOver users find it by its heading.
- **Collecting the errors.** The web's Form reads its fields' errors itself; on iOS you pass the items.
