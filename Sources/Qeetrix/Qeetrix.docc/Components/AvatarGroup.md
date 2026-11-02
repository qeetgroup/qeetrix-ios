# ``Qeetrix/QeetrixAvatarGroup``

## Overview

A few people at a glance — a group's members, an application's users — `@qeetrix/react`'s AvatarGroup:
the first avatars side by side, then +N for the rest.

```swift
QeetrixAvatarGroup(
    people: [
        QeetrixAvatarGroupPerson(name: "Priya Sharma"),
        QeetrixAvatarGroupPerson(name: "Rahul Verma"),
        QeetrixAvatarGroupPerson(name: "Ananya Iyer"),
    ],
    total: 412)
```

- **Avatars**: ``QeetrixAvatar``s, 2 points apart (`border.width.strong`) — side by side, never
  overlapped, so initials stay whole and no surface-coloured ring is needed on a selected or hovered
  row.
- **`max`**: how many avatars show before +N, 3 by default. One left over shows as a face, not "+1".
- **`total`**: how many there are in all, when `people` is only the first few; names may repeat.
- **+N**: a pill the avatars' height, at least as wide, on their fill, in the initials' type with
  tabular figures.
- **Size**: Avatar's — `sm` 24 points (default, for table rows), `md` 32, `lg` 40 or `xl` 48.
- **Shape**: `circle` for people; `square` for organisations, applications or tenants, with a
  square-cornered +N.

```swift
QeetrixAvatarGroup(
    people: products.map { QeetrixAvatarGroupPerson(name: $0) },
    size: .lg, shape: .square,
    label: Text("5 applications: Pay, People, Logs, Notify and ID"))
```

### Accessibility

VoiceOver reads the group as one image, named in full: "412 people: Priya Sharma, Rahul Verma, Ananya
Iyer and 409 more", with the counts and the list in the app's language. For organisations or
applications, say what they are with `label`. Like an avatar, the group keeps its size at every Dynamic
Type setting. In right-to-left layouts the first avatar is on the right and +N on the left.

### Platform differences

- **Images.** The web loads each `src`; on iOS you pass the `Image` you have, as for an avatar.
- **The name.** The web's `messages.label` template becomes a `label` that replaces the whole name.

On the web: [Avatar group on ui.qeet.in](https://ui.qeet.in/components/avatar-group/).

## Topics

### People

- ``QeetrixAvatarGroupPerson``
