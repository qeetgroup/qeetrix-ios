# ``Qeetrix/QeetrixDataState``

## Overview

The four states of loaded content in one place, as `@qeetrix/react`'s DataState: loading, then a
failure, then empty, then the content — in that order, so none is forgotten.

```swift
QeetrixDataState(isLoading: model.isLoading, error: model.error, isEmpty: model.accounts.isEmpty, onRetry: model.reload) {
    AccountList(accounts: model.accounts)
} emptyState: {
    QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus)
}
```

- **Loading** shows an `lg` ``QeetrixSpinner``, centred over the failure state, which is laid out but
  not drawn, so the screen doesn't jump when a load fails.
- **A failure** — any `error` — shows a `section` ``QeetrixEmptyState`` in the danger tone: by
  default `circle-alert`, "Couldn't load this" and "Try again, or check your connection.", and, with
  `onRetry`, a soft "Try again" button. The error itself is never shown: it may hold internals, so log
  it in the app.
- **Empty** shows `emptyState`, usually a ``QeetrixEmptyState`` with your words.
- **The content** is shown as it is, with no wrapper, so a list keeps its place.

The failure can say the app's own words with a ``QeetrixDataStateFailure`` — for example when the
phone is offline:

```swift
let offline = QeetrixDataStateFailure(
    title: "You're offline", description: "Connect to the internet to see your approvals.", icon: .wifiOff)

QeetrixDataState(isLoading: false, error: loadError, failure: isOffline ? offline : .standard, onRetry: reload) {
    ApprovalList()
}
```

The state is the app's: this view loads, retries and caches nothing. Keep showing the content while
you refresh it, and set `isLoading` only when there is nothing to show yet.

### Accessibility

- While loading, VoiceOver finds one element, "Loading"; the failure laid out under the spinner is
  hidden from it and takes no touches.
- A failure is announced as it appears, at high priority, as the web's `role="alert"` is: its title,
  then its description.

### Platform differences

- **Pull to refresh** is the system's control: put `qeetrixRefreshable(announcement:action:)` on the
  content (<doc:PullToRefresh>), which also says when it's done. The data state's retry is for a load
  that failed.
- **The failure's words and icon** are one value, ``QeetrixDataStateFailure``, where the web takes
  `messages`; `icon` lets an offline failure show `wifi-off`.

On the web: [Empty state on ui.qeet.in](https://ui.qeet.in/components/empty-state/), which documents
DataState.

## Topics

### The failure

- ``QeetrixDataStateFailure``
