# ``Qeetrix/QeetrixSidebar``

## Overview

An app's top-level destinations in the sidebar of a `NavigationSplitView` — `@qeetrix/react`'s Sidebar
— and, with ``QeetrixNavigationScaffold``, the same destinations as a tab bar on a phone and a sidebar
beside the detail on a tablet, switching with the width as Android's navigation scaffold does.

```swift
@State private var destination = Destination.accounts

QeetrixNavigationScaffold("Qeet Auth", selection: $destination, items: [
    QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
    QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
    QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
]) { destination in
    NavigationStack {
        DestinationView(destination)
    }
}
```

- **The scaffold** presents the items as a tab bar at compact width — a phone, a narrow Split View — and
  as a `NavigationSplitView` with a `QeetrixSidebar` and the current destination beside it at regular
  width, switching as the window changes. `layout: .bar` or `.sidebar` fixes one. `detail` builds a
  destination's view, usually in its own `NavigationStack`, and the selection is yours.
- **Items.** ``QeetrixNavigationItem`` is a destination: your value, a title, a Qeetrix icon — drawn
  round, as the web draws navigation (design rules §16) — an optional count and `isDisabled` for one
  shown but not available, such as one outside the plan.
- **The current item** is marked as `@qeetrix/react` 0.5.1's sidebar marks it (design rules §11):
  `color.bg.neutral.subtle-hover` behind `color.text.default` at weight 600, the 3-point Ember bar
  (`border.width.accent`, `color.border.brand`) on its leading edge, and its icon in
  `color.icon.brand`, filled where the icon has a filled drawing (`filledWhenCurrent`, on by default).
  In the tab bar the current tab is Ember and its icon filled too.
- **Rows** (sidebar.css) run edge to edge on `color.surface.canvas`: 16 points from the leading edge,
  12 from the trailing, a 16-point icon in `color.icon.subtle`, 10 points to the title (`label.md`,
  `color.text.subtle`) and 10 more to the count (tabular `label.sm`, `color.text.subtlest`). A pressed
  or hovered row takes `color.overlay.pressed` or `color.overlay.hover`; a disabled one is
  `color.text.disabled` with a `color.icon.disabled` icon and no tint.
- **The column** is 256 points wide (`component.sidebar.width-expanded`), titled with the scaffold's
  title, beside the detail (the balanced split-view style), and its toggle is the system's.

Use a `QeetrixSidebar` on its own in a split view you build yourself:

```swift
NavigationSplitView {
    QeetrixSidebar("Qeet Auth", selection: $destination, items: items)
} detail: {
    DestinationView(destination)
}
```

### Accessibility

- VoiceOver reads the sidebar as a group named by its title; each row is a button with its title and
  count, the current one selected, a disabled one dimmed. In the tab bar each tab is the system's,
  read with its position and badge.
- Rows are at least 44 points tall (`size.control.lg` on the web) and sit flush; titles wrap at large
  text sizes rather than truncating, and the row grows.
- Keyboard focus (Full Keyboard Access) draws the 2-point Ember frame inside the row; hover and press
  colours change over `motion.duration.fast`, at once with Reduce Motion.
- In right to left the Ember bar and the icons move to the right edge.

### Platform adaptations

- **System containers.** The tab bar is `TabView`'s and the split view `NavigationSplitView`'s, with
  their gestures, column toggle, keyboard shortcuts and iPad multitasking. Qeetrix draws only the
  sidebar's rows: the system list's selection — a tinted capsule with white text — can't carry the Ember
  bar and the filled icon.
- **Switching** follows the horizontal size class, not a width in points: iOS's counterpart of
  Android's 600 dp breakpoint and the web's 840 px. A destination's own `@State` starts afresh when the
  layout switches, as its views move between containers; keep what must survive in your model or
  `@SceneStorage`.
- **Disabled destinations in the tab bar.** The system tab bar can't dim a tab; a disabled destination
  keeps its tab, and choosing it leaves the current destination as it is.
- **More than five** destinations: on a phone iOS gathers the rest under More.
- **No rail, groups, filter or footer.** The web's collapsed rail, its grouped and nested items, its
  filter and its footer have no counterpart yet; a scaffold's destinations are also its tabs, which
  can't be grouped.
- **iOS 18's adaptable tab view** (`.sidebarAdaptable`) is the system's own tab-bar-to-sidebar; the
  scaffold works from iOS 17 and draws the current item the Qeetrix way.

On the web: [Sidebar on ui.qeet.in](https://ui.qeet.in/components/sidebar/).

## Topics

### Adaptive navigation

- ``QeetrixNavigationScaffold``
- ``QeetrixNavigationLayout``
- ``QeetrixNavigationItem``
