# ``Qeetrix/QeetrixPageIndicator``

## Overview

Where you are in paged content — onboarding, a carousel — as a row of marks, one per page. iOS only:
`@qeetrix/react` has no page indicator, so it is drawn from the design rules.

```swift
@State private var page = 0

TabView(selection: $page) {
    ForEach(slides.indices, id: \.self) { index in
        SlideView(slide: slides[index]).tag(index)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
QeetrixPageIndicator(page: $page, count: slides.count)
```

- **`page`** is the current page's index, from 0; **`count`** how many pages there are.
- **Marks**: an 8-point square per page with the small marks' 2-point corners (`radius.sm`, design
  rules §3), in `color.border.strong`, which keeps 3:1 on every surface; `space.gap.sm` apart.
- **Current page**: marked in Ember (`color.bg.brand.bold`, design rules §4 and §11) and three marks
  wide, so it never rests on colour. It slides over `motion.duration.normal` with
  `motion.easing.standard` whenever the page changes, a swipe in the content included.
- **Disabled**, through `disabled(_:)`: the disabled colours, and it doesn't move.

Up to about ten pages; more want a count ("3 of 24") instead.

### Accessibility

VoiceOver reads the indicator as one adjustable element, "Page 2 of 4": swipe up or down to move a page.
`label` names it where a screen has more than one ("Onboarding"). A tap before the current page moves one
page back and a tap after it one page on, so each target is half the control — at least 44 points wide
whenever there is a page to move to, and 44 tall — rather than an 8-point mark. Under Reduce Motion the
mark jumps. In right-to-left layouts the first page is on the right, and a tap to the left moves on.

### Platform differences

- **No web counterpart.** The marks follow the design rules: square geometry with the small marks'
  corners, Ember for the current item, 3:1 marks.
- **Not the system's page control.** `TabView`'s page indicator draws round system dots in system
  colours; this draws Qeetrix's marks, and moves as the system's does — a tap moves one page.
