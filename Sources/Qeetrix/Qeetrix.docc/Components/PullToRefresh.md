# Pull to refresh

The system's pull to refresh on a list, with `qeetrixRefreshable(announcement:action:)`, saying when
the refresh has finished.

## Overview

Qeet Auth's pending approvals, and its access requests, are refreshed by pulling the list down. On iOS
that is the system's refresh control; Qeetrix adds what it leaves out — telling VoiceOver the refresh
has finished, and the haptic for it.

```swift
List(approvals) { approval in
    QeetrixListItem(approval.app, description: Text(approval.place)) {
        QeetrixListItemIcon(.lock)
    }
}
.qeetrixListStyle()
.qeetrixRefreshable { await model.reload() }
```

- **The refresh** runs while the system's indicator shows, and the indicator stays until `action`
  returns. Keep the rows showing meanwhile, and change them when the new ones arrive.
- **When it has finished**, VoiceOver hears "Updated" — or your words, `announcement:` — once it has
  finished what it is saying, and the success haptic plays. If the refresh is cancelled — the screen
  went away — nothing is said or played.
- **A refresh that can fail** returns a ``QeetrixRefreshResult`` from `qeetrixRefreshable(action:)`,
  so the app's words can depend on what arrived, and a failure isn't announced as "Updated":

```swift
List(approvals) { approval in
    QeetrixListItem(approval.app, description: Text(approval.place))
}
.qeetrixListStyle()
.qeetrixRefreshable {
    do {
        let added = try await model.reload()
        return added == 0 ? .updated : .updated("\(added) new requests")
    } catch {
        toast = .danger("Couldn't refresh your approvals")
        return .failed
    }
}
.qeetrixToast($toast)
```

| Result | VoiceOver hears | Haptic |
|:--|:--|:--|
| `.updated` | "Updated", once current speech has finished (the web's `role="status"`) | ``QeetrixFeedback/success`` |
| `.updated("2 new requests")` | your words, the same way | ``QeetrixFeedback/success`` |
| `.failed` | nothing more: the failure you show — a danger ``QeetrixToast``, a ``QeetrixAlert`` — announces itself | ``QeetrixFeedback/error`` |
| `.failed("Couldn't refresh")` | your words at once, interrupting (`role="alert"`); show the failure too | ``QeetrixFeedback/error`` |

### With a data state

``QeetrixDataState`` leaves pull to refresh to the system: put the modifier on the content it shows.
The first load is the data state's spinner; every later one is the pull, with the rows still showing.
A failed first load has the data state's Try again; an empty list can still be pulled if you show the
empty state inside a scroll view.

```swift
QeetrixDataState(
    isLoading: model.approvals.isEmpty && model.isLoading, error: model.loadError, isEmpty: model.approvals.isEmpty,
    onRetry: model.retry
) {
    List(model.approvals) { approval in
        QeetrixListItem(approval.app, description: Text(approval.place))
    }
    .qeetrixListStyle()
    .qeetrixRefreshable { await model.reload() }
} emptyState: {
    QeetrixEmptyState("No pending approvals", description: "Sign-in requests to approve appear here.", icon: .inbox)
}
```

### What the system draws, and what Qeetrix sets

The control is SwiftUI's `refreshable(action:)`, on a `List` or a `ScrollView`:

- **iOS draws** the indicator above the content, in its own grey (`secondaryLabel`), follows the
  finger as the content is pulled, taps as the pull reaches the point where the refresh starts, and
  holds the indicator while the refresh runs. VoiceOver users refresh with a three-finger swipe down
  at the top of the list.
- **Qeetrix sets** the announcement and the haptic when the refresh ends — the system plays nothing
  then, so the success or error haptic is the only one — and nothing else.

**The tint, precisely.** SwiftUI has no way to tint the refresh control, on any version from iOS 17 to
the iOS 27.1 SDK: `refreshable(action:)` takes only the action, there is no other refresh API, and
`tint(_:)`, `accentColor(_:)` and `foregroundStyle(_:)` don't reach it. SwiftUI's refresh control
carries only the action and sets no tint (iOS 26.5's SwiftUI), and UIKit draws a control without one
in `secondaryLabel` grey, whatever the list's tint (iOS 27's SwiftUI and UIKit, run as Mac Catalyst).
A behaviour test checks it on each iOS the tests run on.
UIKit's own `UIRefreshControl.tintColor` would tint it, but SwiftUI creates the control and gives no
handle to it: setting it means searching SwiftUI's private view hierarchy, or a global
`UIRefreshControl.appearance()` that would reach every refresh control in the app. Qeetrix does
neither (ADR 0014). The system's grey is neutral, as Qeetrix's own spinner is unless asked for Ember,
and design rules §4 keep Ember off a wait anyway: it is for the primary action, focus, the current
item, checked controls and links.

### Accessibility

- **The announcement** is posted once the refresh has returned: an update at low priority, so it waits
  for what VoiceOver is saying; a failure with words at high priority. It is a plain, localised string,
  because it is spoken; never put a secret in it.
- **Reduce Motion** is the system control's own: the content follows the finger — direct
  manipulation, which the setting leaves alone — and the indicator turns while the refresh runs, as
  every system activity indicator does, because it shows that work is going on. Qeetrix adds no
  motion. When the new rows arrive, change them without `withAnimation`, or animate them with
  `QeetrixMotion.animation(_:_:reduceMotion:)`, which is no animation under Reduce Motion.
- **Haptics** follow the system setting: nothing plays with System Haptics off, or on an iPad.
- Pull to refresh is never the only way to fresh content: say how else it updates — a refresh as the
  screen appears, the data state's Try again.

### Platform differences

- **The system's control, not Qeetrix's.** qeetrix-android draws its own indicator — a raised disc
  with the overlay shadow, a progress ring filling as the pull nears the threshold, then the brand
  spinner — over Material's pull. iOS keeps its own control and its grey, untintable from SwiftUI, so
  there is no disc, ring or Ember here.
- **The app's refresh is a function**, where qeetrix-android takes a `refreshing` flag and `onRefresh`:
  the indicator shows until the function returns, so there is no flag to keep in step.
- **The words** are qeetrix-android's: "Updated", or `finishedMessage` — here `announcement` — said
  politely. A ``QeetrixRefreshResult`` adds what Android leaves to the app: words that depend on what
  arrived, and a failure that isn't called "Updated".
- **The haptic at the end** is iOS's: the system taps at the threshold, as qeetrix-android's
  `LightImpact` does, and Qeetrix plays success or error when the refresh ends.
- `@qeetrix/react` has no pull to refresh: a web page has the browser's reload.

## Topics

### Results

- ``QeetrixRefreshResult``
