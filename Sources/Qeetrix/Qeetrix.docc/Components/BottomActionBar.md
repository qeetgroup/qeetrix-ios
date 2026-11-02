# Bottom action bar

A screen's main actions pinned to the bottom of the screen, with
`qeetrixBottomActionBar(primary:secondary:)`.

## Overview

For a screen whose task ends in one action — pay, continue, send — that should stay within reach
however far the screen scrolls.

```swift
ScrollView {
    InvoiceSummary(invoice)
}
.qeetrixBottomActionBar(
    primary: QeetrixScreenAction("Pay ₹1,200", isLoading: isPaying) { pay() },
    secondary: QeetrixScreenAction("Save for later") { save() })
```

- **Actions.** At most one solid action, the `primary`, and one soft one, the `secondary` (design rules
  §7): the bar takes ``QeetrixScreenAction``s, not buttons, so it decides their emphasis and a screen
  can't end up with two primaries. Put anything else — Cancel, Learn more — in the screen. A destructive
  confirmation is the primary with `tone: .danger`. Both are `lg` ``QeetrixButton``s, the field height.
- **Placement.** Above the home indicator, and above the keyboard while it is open: the bar is a bottom
  safe-area inset of the view it modifies, and its surface runs under the home indicator.
- **On a phone** the actions span the bar: side by side at equal widths, the secondary first, when both
  labels fit in half of it; stacked full width, the primary on top, when they don't — at large text
  sizes, or with long labels. A full-width button keeps its label at the start and its icon at the end.
- **On a tablet**, and at any regular width, they keep their own widths, at the end of the bar, as in
  the web's footers.
- **Look.** `color.surface.default` with the page gutter (16 points at compact width, 32 at regular,
  page-header.css) and 12 points above and below the buttons, 8 points apart. While content runs
  beneath the bar, a 1-point `color.border.default` rule marks its top edge.

Apply the modifier to the screen's scroll view (a `ScrollView`, `List` or `Form`): the content scrolls
under the bar and can scroll clear of it. Disabled, busy and destructive actions are set on the
action itself: `isDisabled`, `isLoading`, `tone`.

### Accessibility

- The buttons are ``QeetrixButton``s: VoiceOver reads each by its title, a busy one as "Loading", a
  disabled one as dimmed. They are read in the order they are drawn — side by side, the secondary
  first; stacked, the primary first.
- Each button is at least 44 points tall to the touch; the labels wrap at the accessibility sizes and
  the bar stacks them rather than truncating.
- The rule appears over `motion.duration.fast`, at once with Reduce Motion. The layout mirrors in right
  to left: the secondary on the right, the primary on the left.

### Platform adaptations

- **iOS only.** `@qeetrix/react` has no bar pinned to a screen's edge; the bar is built from its
  Button, the page gutter and the footer's spacing.
- **The rule from iOS 18.** On iOS 18 and later the bar reads the scroll view's geometry
  (`onScrollGeometryChange`) and shows the rule only while content is under it. iOS 17 can't read a
  scroll position without a view inside the content, which the bar doesn't own, so there the rule
  always shows: the bar's edge, as on a toolbar. Without a scroll view the rule doesn't show on iOS 18.
- **Keyboard.** The bar rides above the keyboard, as iOS moves safe-area insets; there is no separate
  keyboard toolbar.

## Topics

### Actions

- ``QeetrixScreenAction``
