# ``Qeetrix/QeetrixTabs``

## Overview

A row of tabs that switches between panels of related content in one place — a card's views, a
settings page's sections. The strip selects; you own the selection and draw the panel for it.

```swift
@State private var section = Section.overview

QeetrixTabs(selection: $section, tabs: [
    QeetrixTab("Overview", value: Section.overview),
    QeetrixTab("Activity", value: Section.activity, icon: .bell),
    QeetrixTab("Archive", value: Section.archive, isDisabled: true),
])
switch section {
case .overview: OverviewPanel()
case .activity: ActivityPanel()
case .archive: EmptyView()
}
```

- `default` is contained: a sunken well with the selected tab raised inside it. `line` sits on a 1 pt
  track and marks the selected tab with a 2 pt brand indicator — for a page's sections.
- Tabs follow the density's control height; labels are `text-sm` medium and never truncate.
- A strip wider than its container scrolls sideways and brings the selected tab into view, without
  animation when Reduce Motion is on.
- A disabled tab is dimmed and can't be chosen.

Use it for in-content selection. The app's main sections belong in a `TabView` (see
<doc:NavigationBars>); two or three options in a form are a ``QeetrixRadioGroup``.

### Accessibility

The strip carries the tab-bar trait, and each tab is a button with the selected state on the chosen one,
so VoiceOver can present the strip as a group of tabs. Each tab's touch target is at least 44 pt.

### Platform differences

The web's arrow-key roving focus is the system's focus movement on iOS. Panels are not part of the
component: on the web `TabsContent` mounts the panel, here your view switches on the selection, so the
panel's state lives wherever you keep it.

On the web: [Tabs on ui.qeet.in](https://ui.qeet.in/docs/components/tabs).

## Topics

### Tabs

- ``QeetrixTab``
- ``QeetrixTabsVariant``
