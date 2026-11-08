# ``Qeetrix/QeetrixPermissionPrimer``

## Overview

Why the app needs a permission — the camera, location, notifications, photos or contacts — before iOS
asks for it, and the way back to it once it's been turned off. On a screen of its own, or in a sheet.

```swift
QeetrixPermissionPrimer(
    .notifications, status: status,
    title: "Know when a payment arrives",
    message: "Qeet Pay sends a notification when a customer pays an invoice. Nothing else.",
    onContinue: requestAuthorization, onNotNow: dismiss)
```

Qeetrix never asks for a permission itself. The app reads the status from the framework that owns it
(`AVCaptureDevice`, `CLLocationManager`, `UNUserNotificationCenter`, `PHPhotoLibrary`, `CNContactStore`),
passes it in, and makes the request in `onContinue`:

- **`notDetermined`**: **Continue** (`solid`, with `arrow-right`), which leads to the system's alert. It
  says "Continue", not "Allow", as Apple's guidelines ask: the system's alert is where the person allows it.
- **`denied`**: iOS won't ask again, so **Open Settings** (`solid`, with `external-link`) opens the app's
  page in Settings — its notification settings for `.notifications` — unless `onOpenSettings` does
  something else.
- **Not now** (`ghost`, short and centred) in both, when there's an `onNotNow`.

The layout is `@qeetrix/react`'s EmptyState (empty-state.css): centred and at most 480 points wide,
the kind's 24-point sharp icon in `color.icon.subtle` (`camera`, `map-pin`, `bell`, `image`,
`contact-round`), the title in `title.md`, the message in `body.md` and `color.text.subtle`, `space.gap.sm`
apart, with `space.layout.lg` above and below. The actions are `lg` — one solid action at most (design
rules §7): the primary full width with its icon in the trailing zone, as Qeet's full-width buttons
carry one, and Not now short under it. The arrows point the way the layout reads, mirrored right to
left.

A footnote under the actions says what the permission is used for and what it isn't, centred in
`body.sm` and `color.text.subtle`:

```swift
QeetrixPermissionPrimer(
    .notifications, title: "Approve sign-ins from this phone",
    message: "Qeet ID notifies you when you sign in somewhere new.",
    onContinue: requestAuthorization, onNotNow: dismiss
)
.footnote(Text("Only sign-in requests. Nothing else, no marketing."))
```

Say in `message` what the app does with the permission, in a sentence or two, and why now. In a sheet:

```swift
.qeetrixSheet(isPresented: $asksForLocation) {
    QeetrixPermissionPrimer(
        .location, title: "Find branches near you",
        message: "Qeet People uses your location only while you look for a branch.",
        onContinue: requestLocation, onNotNow: { asksForLocation = false })
}
```

`messages` replaces the button titles, for words of your own or a language Qeetrix doesn't have yet.

### Accessibility

The title is a heading (level 2, or `headingLevel`); the icon is decorative. The buttons have 44-point
touch targets and span the column, and the text wraps at every size.

### Platform differences

`@qeetrix/react` has no permission primer: a browser asks for a permission in its own way. This one is
built on EmptyState's layout and the design rules' button hierarchy; its words follow Apple's guidance
for a screen shown before the system's alert. A restricted permission (Screen Time, a device-management
profile) can't be granted from here: show `denied`, and say who manages the device.

On the web: [EmptyState on ui.qeet.in](https://ui.qeet.in/components/empty-state/), whose layout it
takes.

## Topics

### Options

- ``QeetrixPermissionPrimerKind``
- ``QeetrixPermissionPrimerStatus``
- ``QeetrixPermissionPrimerMessages``
