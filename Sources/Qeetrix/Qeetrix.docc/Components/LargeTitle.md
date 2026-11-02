# Large and collapsing titles

The system's large-title navigation bar with its titles in Qeet Sans, with
`qeetrixNavigationBar(background:title:)`.

## Overview

A screen at the top of a navigation stack — a list, a home screen — names itself in a large title that
collapses into the bar as the screen scrolls. On iOS that is the system navigation bar's large title;
Qeetrix gives it Qeetrix type.

```swift
NavigationStack {
    List(accounts) { account in
        Text(account.name)
    }
    .navigationTitle("Accounts")
    .navigationBarTitleDisplayMode(.large)
    .qeetrixNavigationBar(title: .qeetrix)
}
```

- **Type.** With `title: .qeetrix` the large title is `heading.lg` (32 points, weight 600, the heading
  letter style) and the inline title, once it has collapsed, `title.md` (18 points), both in
  `color.text.default`. With `.system`, the default of `qeetrixNavigationBar()`, iOS draws both in its
  own font.
- **Large or inline** is `navigationBarTitleDisplayMode(_:)`, as without Qeetrix: `.large` for a
  screen at the top of a stack, `.inline` for one further down, `.automatic` to follow the stack.
- **The edge.** At the scroll edge the bar has no line; once content scrolls under it, a 1-point
  `color.border.default` rule — the foot of the web's PageHeader.
- **Background.** `.automatic` keeps the system's: clear at the scroll edge, its material once content
  is under the bar. `.canvas` keeps `color.surface.canvas` behind the bar throughout.
- **Tint.** The back button and the bar's buttons are Ember (`color.text.brand`), as with every
  `qeetrixNavigationBar`.

Apply the modifier to each destination, as you do `navigationTitle(_:)`; the styling belongs to that
screen and leaves with it on push and pop.

```swift
NavigationStack {
    InvoiceList()
        .navigationTitle("Invoices")
        .qeetrixNavigationBar(background: .canvas, title: .qeetrix)
}
```

### Accessibility

- The large title grows with Dynamic Type, along the `.largeTitle` curve as the system's does, and takes
  one weight step more with Bold Text.
- The inline title stays at its size, as the system's does, because the bar's height is fixed; touch
  and hold it at the accessibility sizes and the system's Large Content Viewer shows it larger.
- `color.text.default` on the bar's backgrounds is well above 4.5:1 in both schemes.

### Platform adaptations

- **Android's medium and large top app bars** are the same idea; iOS has one large size and the inline
  bar, both the system's, and the collapse is the system's own, driven by the scroll view.
- **The web** has no collapsing title: its PageHeader keeps a `title.lg` heading at the top of the page.
- **How it is set.** SwiftUI has no API for a bar's title font, so Qeetrix sets it on the UIKit
  appearance of the destination's navigation item — the one place iOS lets an app choose it — and the
  background with it, so one owner writes that appearance. The bar's layout, its collapse, back
  navigation and toolbars are untouched.
- **Truncation.** iOS truncates a large title too long for one line; keep large titles short.

On the web: [Page header on ui.qeet.in](https://ui.qeet.in/components/page-header/).

## Topics

### Options

- ``QeetrixNavigationBarTitle``
- ``QeetrixNavigationBarBackground``
