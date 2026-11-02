# Navigation and tab bars

Qeetrix styling for the system navigation bar and tab bar. The bars, and the navigation, stay the
system's and the app's.

## Overview

Navigation on iOS is a `NavigationStack` with its bar, and a `TabView` with its tab bar. Qeetrix doesn't
replace them: back navigation, the swipe-back gesture, large titles, toolbar layout and the tab bar's
adaptation to a sidebar on iPad all stay the system's. Qeetrix sets what the platform lets an app set.

```swift
@State private var tab = AppTab.home

TabView(selection: $tab) {
    NavigationStack {
        HomeView()
            .navigationTitle("Home")
            .qeetrixNavigationBar()
    }
    .qeetrixTabItem("Home", icon: .house)
    .tag(AppTab.home)

    NavigationStack {
        InboxView()
            .navigationTitle("Inbox")
            .qeetrixNavigationBar(background: .canvas)
    }
    .qeetrixTabItem("Inbox", icon: .inbox, badge: unreadCount)
    .tag(AppTab.inbox)
}
.qeetrixTabBar()
```

- `qeetrixNavigationBar(background:)` puts the brand tint (`color.text.brand`) on the bar's buttons and,
  with `.canvas`, `color.surface.canvas` behind the bar at all times. Apply it to each destination, as you
  do `navigationTitle(_:)`.
- `qeetrixTabBar()` puts Ember (`color.icon.brand`) on the current tab, as the web marks its current
  navigation item.
- `qeetrixTabItem(_:icon:badge:)` makes a tab from a title, a Qeetrix icon — round, as the web draws
  navigation icons (design rules §16) — and an optional count.
- For toolbar buttons, use a `Label` with `Image(qeetrix:)` as its icon: the bar shows the icon and
  VoiceOver reads the title.

The selected tab and every navigation path are your state. Keep them in `@State`, `@SceneStorage` or
your model, as you would without Qeetrix; nothing in the design system routes or remembers.

### Accessibility

The bars are the system's, so VoiceOver, Full Keyboard Access, Dynamic Type and Bold Text behave as in
any app. Name every icon-only toolbar button with a `Label`.

### Platform differences

`@qeetrix/react`'s Sidebar, TopBar and the rest of its console frame have no iOS counterpart: a phone
uses the navigation stack and tab bar, and iPad's sidebar adaptation comes from `TabView`. The bars are
the system's, so the web's Ember bar on the current item and its filled current icon don't apply; the
bar's title is drawn in the system font. For views within a screen, use ``QeetrixTabs``.
