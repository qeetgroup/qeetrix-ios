# ``Qeetrix/QeetrixDataState``

## Overview

The loading, failure and empty branches of a surface that shows loaded data, in one place — so none is
forgotten.

```swift
QeetrixDataState(isLoading: model.isLoading, isEmpty: model.members.isEmpty,
                 failure: model.failed ? QeetrixDataFailure("Couldn't load members.") { model.reload() } : nil) {
    MemberList(members: model.members)
} empty: {
    QeetrixEmptyState("No members yet", description: Text("Invite people to this workspace."))
}
```

- **Order.** Loading, then a failure, then empty, then the content — as the web's `DataState`.
- **Loading** shows six skeleton rows (``QeetrixDataLoadingRows``), or your own `loading` view in the
  shape of the content.
- **A failure** shows an error ``QeetrixEmptyState`` with your message, and "Try again" when you pass a
  retry action.
- **Transitions** fade in the standard easing, or switch at once with Reduce Motion on.

The state is yours: nothing is fetched, retried or cached here. While refreshing content that is already
on screen, keep it visible (`refreshable(action:)`) and leave `isLoading` false.

### Accessibility

The loading branch is one element, "Loading", however many placeholders it draws, and it announces
nothing while it waits. A failure is announced when it appears, at high priority, as the web's
`role="alert"`.

### Platform differences

The web's default error slot shows the error object's message. On iOS the failure takes a message you
write for the person — a raw error is never shown — and an optional retry.

On the web: [Data State on ui.qeet.in](https://ui.qeet.in/docs/components/data-state).

## Topics

### Branches

- ``QeetrixDataFailure``
- ``QeetrixDataLoadingRows``
