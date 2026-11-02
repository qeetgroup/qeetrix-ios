# ``Qeetrix/QeetrixAvatar``

## Overview

A person, organisation or application: their photo or logo, or their initials — `@qeetrix/react`'s
Avatar.

```swift
HStack {
    QeetrixAvatar(name: "Priya Sharma")
    QeetrixAvatar(name: "Priya Sharma", size: .lg)
    QeetrixAvatar(name: "Kaveri Foods Private Limited", shape: .square)
}
```

- **Size**: `sm` 24, `md` 32 (default), `lg` 40 or `xl` 48 points.
- **Shape**: `circle` for a person — people are one of the two soft shapes — or `square`, with the
  controls' 4-point corners, for an organisation, an application or a tenant, so it never reads as a
  person.
- **Initials** on `color.bg.neutral.subtle-pressed`, in `label.sm` (`label.md` at `lg` and `xl`): the
  first character of the first and last words ("Priya Sharma" is "PS"). A company's legal form doesn't
  count ("Kaveri Foods Private Limited" is "KF"), and a name left with one word takes its first two
  ("Acme Pvt Ltd" is "AC"). Characters are grapheme clusters, so Indic names stay whole.
- **Image**: drawn to fill the shape, clipped to it.

### Accessibility

VoiceOver reads the avatar as an image named by `name`. Where the name is shown beside it, pass
`isDecorative: true` and it is hidden.

### Platform differences

- **Images.** The web loads `src` and shows the initials while it loads or if it fails; on iOS you pass
  the `Image` you have, so loading is yours.
- **Initials size.** The initials sit in a fixed-size graphic, so they don't grow with Dynamic Type.

On the web: [Avatar on ui.qeet.in](https://ui.qeet.in/components/avatar/).

## Topics

### Styling

- ``QeetrixAvatarSize``
- ``QeetrixAvatarShape``
