# ``Qeetrix/QeetrixAvatar``

## Overview

A person's picture, their initials, or a neutral icon.

```swift
HStack {
    QeetrixAvatar(name: "Asha Rao")
    QeetrixAvatar(name: "Asha Rao", size: .lg, badge: Text("Online"))
    QeetrixAvatar(name: "Qeet Group", shape: .square)
}
```

- **Sizes.** `xs` 20, `sm` 24, `default` 32, `lg` 40 and `xl` 48 pt. They are fixed: an avatar is a
  recognition target, so a person looks the same size everywhere.
- **Shapes.** `circle` for people; `square` for organisations, workspaces and apps.
- **Fallbacks.** Without an image, the initials of the name — the first letters of its first and last
  words — and without a name, the `user-round` icon.
- **Badge.** A status mark at the bottom-trailing edge.

### Accessibility

- VoiceOver reads the avatar as one image called by the name, then the badge's text: "Asha Rao,
  Online". Colour alone is never the status.
- Pass `name: nil` when the name is already visible beside the avatar, so it is not read twice. The
  avatar is then hidden from VoiceOver, unless it has a badge.

### Platform adaptations

- **Images.** The web loads a URL and fades the photo in. Here the avatar takes an `Image` your app
  has already loaded, so caching and errors stay with the app's image pipeline.
- **Initials at large text sizes.** The initials keep their size, as the avatar does, rather than grow
  with Dynamic Type and overflow it.

On the web: [Avatar on ui.qeet.in](https://ui.qeet.in/docs/components/avatar).

## Topics

### Styling

- ``QeetrixAvatarSize``
- ``QeetrixAvatarShape``
