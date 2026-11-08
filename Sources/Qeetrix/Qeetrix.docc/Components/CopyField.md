# ``Qeetrix/QeetrixCopyField``

## Overview

A read-only value with its Copy button — `@qeetrix/react`'s CopyField: an ID, a URL to paste
elsewhere, a secret shown once.

```swift
QeetrixCopyField("ACS URL", value: acsURL, description: Text("Paste it into your identity provider."), toast: $toast)
QeetrixCopyField("Client secret", value: secret, isSensitive: true, toast: $toast)
```

- **The field** (`layout: .field`, the default) is a ``QeetrixField``: the label in `label.sm`,
  `color.text.subtle`, above the read-only field box, then the description in `body.sm`. The box has no
  fill and the field's `color.border.strong` bottom line — what a read-only ``QeetrixTextField`` shows
  — is at least `size.control.lg` tall, and holds the value `space.inset.md` from its start
  and a ghost, neutral `sm` ``QeetrixCopyButton`` `space.inset.xs` from its end, `space.gap.sm` apart.
- **The value** is `code.sm` in `color.text.default`, `space.inset.xs` above and below. It reads left to
  right in every language, as a code does, and wraps rather than scrolls: a long URL breaks onto more
  lines. `wrap: .none` keeps it on one line, ending in an ellipsis. A long press selects it, to copy
  part of it.
- **Copy** is named after the label — "Copy ACS URL" — copies the whole value, and confirms with a light
  haptic and, given the screen's toast binding, a "Copied" toast (see ``QeetrixCopyButton``).
- **Secrets.** `isSensitive` keeps the clipboard entry on this device and has the system remove it after
  60 seconds; the value is marked `privacySensitive()`, so it is redacted where the system hides
  private content. Show a secret only once, and only while the person needs it.

### A row on a record page

`layout: .row` lays the label and the value side by side as a ``QeetrixDescriptionItem`` does, so a copy
field lines up with the facts around it. In a ``QeetrixDescriptionList`` it is ruled like them, and, as
they do, the label moves above the value where the list is narrow — a phone in portrait.

```swift
QeetrixDescriptionList {
    QeetrixDescriptionItem("Name", value: tenant.name)
    QeetrixCopyField("Tenant ID", value: tenant.id, layout: .row, toast: $toast)
}
```

### Accessibility

- VoiceOver reads the value as text named by the label — "ACS URL, https://id.qeet.in/…" — with the
  description as its hint, then the Copy button, "Copy ACS URL".
- The Copy button's touch target is 44 points, extended without moving layout.
- The value wraps at every text size; at the accessibility sizes even `wrap: .none` wraps, so nothing is
  hidden behind an ellipsis.
- Disable the whole field with `disabled(_:)`: the box takes the disabled fill and line.

### Platform differences

- **Selecting.** The web selects the whole value with one click; on iOS a long press selects it, and the
  Copy button copies all of it.
- **Rows on a phone.** copy-field.css keeps a row's label beside its value at every width, while
  DescriptionItem stacks below 24 rem; iOS stacks the row as the description list does, so the two line
  up.
- **Rules between rows** come from the ``QeetrixDescriptionList`` the rows are in; the web rules two
  copy-field rows that follow each other.
- **Secrets, toast and haptics** as on ``QeetrixCopyButton``.

On the web: CopyField, `@qeetrix/react`'s experimental `copy-field` family (no ui.qeet.in page yet).

## Topics

### Options

- ``QeetrixCopyFieldLayout``
- ``QeetrixCopyFieldWrap``
