# Icons

Draw Qeetrix icons in their round and sharp shapes, outline and filled.

## Overview

``QeetrixIcon`` draws an icon from `@qeetrix/icons` 2.1 as vector paths, in the current foreground
style:

```swift
QeetrixIcon(.search)
QeetrixIcon(.bell, size: .lg, variant: .filled)
QeetrixIcon(.x, shape: .sharp)
```

The defaults match the web's icon components: size ``QeetrixIconSize/md`` (20 points), stroke
``QeetrixIconStroke/regular``, round outline. The stroke is measured on the icon's 24-unit grid, so it
scales with the icon. The sizes are `size.icon.*`: ``QeetrixIconSize/xs2`` 12, ``QeetrixIconSize/xs``
14, ``QeetrixIconSize/sm`` 16, ``QeetrixIconSize/md`` 20 and ``QeetrixIconSize/lg`` 24 points.

## Which shape and variant

Qeetrix's own components follow the icon rules of the design (design rules §16):

- **Sharp in controls.** Buttons, fields, badges, menus and toasts draw their icons in the sharp
  shape — square ends and mitred corners, matching the square corners. Navigation (tab bars) keeps the
  round shape, which reads more calmly in a list.
- **Outline by default; filled only for a selected or active state**, such as a selected tab
  (`filledWhenSelected`, on by default). If an icon has no filled drawing, the state is shown by the Ember bar or tint
  instead.
- **Sizes:** 16 points inside controls (20 in a large button), 20 standalone, 24 in empty states.
- **Colour:** `iconDefault` or `iconSubtle`; Ember only when the icon is part of a current or selected
  item.

Not every icon has every drawing. Ask ``QeetrixIconName/hasDrawing(_:_:)``; a missing drawing falls back
to the outline.

The names are `@qeetrix/icons`' names, which are Lucide's. `Qeetrix` carries the icons its components and
the showcase use (``QeetrixIconName/allCases``). Every other `@qeetrix/icons` icon is in the optional
`QeetrixIconsExtended` product of the same package, by the same kind of name:

```swift
import QeetrixIconsExtended

QeetrixIcon(.alarmClock)
QeetrixEmptyState("No reminders", icon: .alarmClock)
```

An app that doesn't add that product compiles none of it; one that does links only the icons it names.
`QeetrixIconName.extendedCases` lists them all, for an icon picker, and links every one.

The set grows, so ``QeetrixIconName`` is an open set of names, not an enum: adding an icon never
breaks your code. A `switch` over icon names needs a `default` case.

## In system chrome

Tab items, toolbar buttons and menu items accept only an `Image`. `Image(qeetrix:size:shape:variant:stroke:)`
renders an icon into a template image, which takes the bar's or menu's tint as an SF Symbol does:

```swift
Button { share() } label: {
    Label { Text("Share") } icon: { Image(qeetrix: .share2) }
}
```

The system sizes these images, and they don't mirror in right-to-left layouts, so keep the directional
icons for your own views. Inside your own views, use ``QeetrixIcon``, which scales with Dynamic Type.

## Accessibility

An icon is decorative unless you label it. Decorative icons are hidden from VoiceOver, because the text
beside them already says what they mean. Give a stand-alone icon a label that says what it means, not
what it shows:

```swift
QeetrixIcon(.lock, label: Text("Locked"))
```

Icons scale with Dynamic Type relative to `.body`, like SF Symbols beside text. Pass `relativeTo:` to
follow another text style, or `nil` for a fixed size. Icons whose meaning has a direction — the
manifest's `directionality: "mirror"`, such as ``QeetrixIconName/send`` — mirror in right-to-left
languages.
