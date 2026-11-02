# ``Qeetrix/QeetrixQRScanner``

## Overview

A QR scanner's screen around the camera preview your app supplies: the viewfinder, the torch, the
camera's permission states and a way to type the key instead. Qeetrix has no camera code — the app runs
AVFoundation, decodes the codes and switches the torch; it passes its preview in and the state down.

```swift
QeetrixQRScanner(
    state: scannerState, isTorchOn: $isTorchOn,
    messages: QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page")),
    onContinue: requestCameraAccess, onTypeKey: { isTypingKey = true }
) {
    CameraPreview(session: session)
}
```

The app maps the camera's status to a ``QeetrixQRScannerState``:

| Camera | State | What it shows |
|:--|:--|:--|
| Authorised, with a capture device | `scanning` | The preview, the scrim, the target, the guidance and the torch |
| `.notDetermined` | `notDetermined` | The camera's ``QeetrixPermissionPrimer``: Continue calls `onContinue`, where the app asks iOS |
| `.denied` or `.restricted` | `denied` | The primer's denied state: Open Settings opens the app's settings |
| No capture device | `unavailable` | `camera-off`, "No camera", and no actions |

- **The viewfinder.** The preview fills the scanner under `color.overlay.scrim`, with a square hole —
  the target, 70% of the width and at most 280 points — whose four corners are 3-point
  (`border.width.accent`) right angles, 24 points along each edge, in `color.icon.default`, drawn on the
  scrim just outside the hole. The guidance (`label.md`, `color.text.default`) is above the target and
  the torch below, `space.gap.xl` apart. The viewfinder is drawn in the dark scheme whatever the app's,
  as a camera's is: over the dark scrim the guidance keeps 4.5:1 and the corners 3:1 even when the
  camera sees white. The target gives way when large text needs the height.
- **The torch** appears when `isTorchOn` is given — leave it `nil` where the camera has none. It is the
  web's icon-only Toggle at `lg`: `flashlight-off` in `color.text.subtle` while off; a filled
  `flashlight` in `color.text.inverse` on `color.bg.neutral.bold` while on. Switch the torch on the
  capture device when the binding changes.
- **Type the key instead**: with `onTypeKey`, a full-width `soft` button with the `keyboard` icon in a
  ruled `color.surface.raised` panel under every state, so the other way in is always in the same place.

`messages` replaces any of the scanner's words: the guidance, the torch's name, the fallback, the
permission states' titles and messages, and the primer's buttons.

### Accessibility

- VoiceOver reads the guidance, then the torch as a switch ("Torch, off"), then the fallback. The scrim
  and corners are hidden; hide or label your preview as it needs.
- When you've decoded a code, say so: announce it, or move on to the next screen. Don't rely on the
  camera alone — the fallback is there for anyone who can't scan.
- The text wraps at the accessibility sizes, and the torch's square grows with its icon. Nothing in the
  scanner moves, so Reduce Motion changes nothing.
- Right to left, the layout mirrors; the target and the corners are symmetrical.

### Platform differences

`@qeetrix/react` has no scanner: a web page can't count on a camera. This one follows the design rules
— the scrim from `color.overlay.scrim`, the corners at the Ember bar's 3 points, sharp icons, the
button hierarchy — and the web's Toggle for the torch, whose off icon (`color.text.subtle`) keeps 3:1
over the dark scheme's scrim whatever the camera sees.

## Topics

### Options

- ``QeetrixQRScannerState``
- ``QeetrixQRScannerMessages``
