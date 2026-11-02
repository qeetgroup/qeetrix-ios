# ``Qeetrix/QeetrixTabs``

## Overview

Switch between views of the same context — `@qeetrix/react`'s Tabs list. The selection is yours; show
the selected view below it.

```swift
@State private var section = Section.overview

QeetrixTabs(
    selection: $section,
    tabs: [
        QeetrixTab("Overview", value: Section.overview),
        QeetrixTab("Activity", value: Section.activity, icon: .bell, badge: 3),
        QeetrixTab("Archive", value: Section.archive, isDisabled: true),
    ])
switch section {
case .overview: Text("Overview")
case .activity: Text("Activity")
case .archive: EmptyView()
}
```

- **Tabs** are `size.control.lg` tall with 16 points of inline padding (12 at compact density),
  `label.md` in `color.text.subtle` (`color.text.default` under a pointer); an optional leading 16-point
  sharp icon, filled while selected (`filledWhenSelected`, on by default); and a count after the label
  as a neutral `sm` badge.
- **Selected**: `color.text.default` at weight 600, marked by the Ember bar — 3 points of
  `color.border.brand` on its bottom edge — which slides between tabs over `motion.duration.normal`.
- **Variant**: `line` (default), for the views of a page, with a 2-point `color.border.subtle` line under
  the whole list; or `contained`, a segmented strip for a few views of one panel or card — a 1-point
  `color.border.default` edge round it and between segments, the neutral fill, the selected segment on
  `color.surface.default` with the Ember bar.
- **Disabled** tabs are `color.text.disabled`.

```swift
QeetrixTabs(
    selection: $section,
    tabs: [QeetrixTab("Overview", value: Section.overview), QeetrixTab("Activity", value: Section.activity)],
    variant: .contained)
```

The list scrolls sideways when its tabs don't fit, keeping the selected one in view.

### Accessibility

VoiceOver reads the list as a tab bar and each tab as a button that is selected or not. Each tab is a
44-point target. Under Reduce Motion the bar moves without sliding. Keyboard focus is the Ember frame
inside the tab, where a scrolling list can't clip it.

### Platform differences

- **Panels.** The web's Tabs own their panels; on iOS you show the selected view yourself.
- **Vertical tabs** and the web's `activateOnFocus` have no counterpart.
- For an app's top-level sections, use the system `TabView` with `qeetrixTabBar()` — see
  <doc:NavigationBars>.

On the web: [Tabs on ui.qeet.in](https://ui.qeet.in/components/tabs/).

## Topics

### Tabs

- ``QeetrixTab``
- ``QeetrixTabsVariant``
