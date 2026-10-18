# Icons

Draw Qeetrix icons in their round and sharp, outline and filled forms.

## Overview

``QeetrixIcon`` draws an icon from `qeetrix-icons` as vector paths, in the current foreground style:

```swift
QeetrixIcon(.search)
QeetrixIcon(.bell, size: .lg, variant: .filled)
QeetrixIcon(.x, shape: .sharp)
```

The defaults match the web's `<Icon>`: size ``QeetrixIconSize/md`` (20 points), stroke
``QeetrixIconStroke/regular``, round outline. The stroke is measured on the icon's 24-unit grid, so it
scales with the icon.

Not every icon has every drawing. Ask ``QeetrixIconName/hasDrawing(_:_:)``. A missing drawing falls
back to the outline.

The names are the `qeetrix-icons` names, which are Lucide's. This release includes a representative
set (``QeetrixIconName``); the full catalogue comes later.

## Accessibility

An icon is decorative unless you label it. Decorative icons are hidden from VoiceOver, because the text
beside them already says what they mean. Give a stand-alone icon a label that says what it means, not
what it shows:

```swift
QeetrixIcon(.lock, label: Text("Locked"))
```

Icons scale with Dynamic Type relative to `.body`, like SF Symbols beside text. Pass `relativeTo:` to
follow another text style, or `nil` for a fixed size. Icons whose meaning has a direction, such as
``QeetrixIconName/send``, mirror in right-to-left languages.
