# ✨ Icons

Every `@qeetrix/icons` icon is available on iOS by its upstream name, in both shapes (sharp on controls, round in
navigation), outline and — where upstream draws one — filled, mirrored in right to left where the meaning has a
direction. qeetrix-android carries the same names at the same `@qeetrix/icons` version.

## 📦 Two products

| Product | Icons | Name |
|:--|:--|:--|
| `Qeetrix` | The 100 core icons: what the components and the showcase draw | `.send` |
| `QeetrixIconsExtended` (optional) | The other 1,763 | `.alarmClock`, after `import QeetrixIconsExtended` |

Both are in the same package, so they are always the same version. Add the second product to a target that needs it:

```swift
.product(name: "QeetrixIconsExtended", package: "qeetrix-ios")

import Qeetrix
import QeetrixIconsExtended

QeetrixButton("Scan", icon: .qrCode) { scan() }                      // core
QeetrixEmptyState("No reminders", icon: .alarmClock)                 // extended
```

Every component that takes an icon takes either kind: both are `QeetrixIconName`. Two names are equal when their raw
values (`"alarm-clock"`) are; switch over them with a `default` case, since the catalogue grows with `@qeetrix/icons`.
`QeetrixIconName.allCases` lists the core icons and `QeetrixIconName.extendedCases` the extended ones, for an icon
picker or a gallery such as the showcase's Icons page. `QeetrixIconName(rawValue:)` finds core icons only.

## 📏 What an app pays

The package is built from source, so an app that doesn't add `QeetrixIconsExtended` compiles none of it. In one that
does, each icon is an `@_alwaysEmitIntoClient` property holding its drawings as compact path strings, decoded the first
time the icon is drawn: the library itself compiles no icon, and each one is compiled into the app only where the app
names it. (A stored `static let` wouldn't do: Swift marks every public symbol a library defines as one the linker must
keep, so all 1,763 icons would ship in every app.)

**Budget:** 4 KiB per extended icon an app uses. `Scripts/icon-budget.sh` (part of `Scripts/check.sh`, the local gate) builds
`Tools/IconBudget` in release twice — one core icon, then twenty extended ones as well — and fails unless the first
program carries no extended icon's drawings, the second exactly the twenty, and the second is no more than 20 × 4 KiB
larger. Naming `QeetrixIconName.extendedCases` keeps every icon, so an app that draws fixed icons names them instead.

## 🔄 Where the icons come from

`Upstream/pins.json` pins `@qeetrix/icons`; `Scripts/sync-upstream.sh` copies every icon's catalogue entry and SVG
drawings into `Upstream/qeetrix-icons/`, and `Scripts/generate.sh` writes the Swift: the core icons into
`Sources/Qeetrix/Icons/Generated/QeetrixIconCatalog.swift`, every other one into
`Sources/QeetrixIconsExtended/Generated/`, one file per first letter. Nothing there is edited by hand; CI fails if a
generated file drifts from the snapshot.

- **A new `@qeetrix/icons` version:** bump the pin, sync, generate. New icons appear in the extended product; an icon
  upstream removes or renames disappears and the build names it.
- **An icon a component or the showcase now draws:** add its name to the `icons` list in `Upstream/pins.json`, so it
  moves into the core set, then sync and generate. Apps keep writing `.name`; they no longer need the extended import
  for it.
