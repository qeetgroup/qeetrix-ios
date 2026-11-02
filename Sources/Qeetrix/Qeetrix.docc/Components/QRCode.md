# ``Qeetrix/QeetrixQRCode``

## Overview

Text a phone camera can read — an `otpauth://` link that adds an account to an authenticator, a UPI
payment link — as `@qeetrix/react`'s QRCode (experimental): the same modules as the web's for the same
value and level, always dark on white.

```swift
VStack(spacing: QeetrixSpace.gapLg) {
    QeetrixQRCode(setupLink, label: "QR code to add Acme to your authenticator app", text: Text(setupKey))
    QeetrixQRCode(upiLink, label: "QR code to pay Acme Traders by UPI", level: .q, text: Text("acme@upi"))
}
```

- **Encoding**: Qeetrix's own encoder (ISO/IEC 18004), the web's ported line for line: the value as
  UTF-8 in byte mode; the smallest of versions 1 to 40 that holds it at `level`; Reed–Solomon over
  GF(256) with the blocks interleaved; BCH-coded format and version words; and, of the eight masks, the
  first with the lowest penalty under the web's four rules. So a value draws exactly the modules it
  draws on the web.
- **Level**: how much of the code can be lost and still read — `l` 7%, `m` 15% (default), `q` 25%,
  `h` 30%. A higher level makes a denser code for the same value.
- **Size**: `size` points square, 160 by default, the four-module quiet zone included.
- **Look** (qr-code.css): `color.text.default` modules on `color.surface.default` inside a hairline
  `color.border.subtle` tile with `radius.control` corners — in the light scheme's values whatever the
  colour scheme, since a camera needs the dark-on-light contrast either way. Whole modules, each edge
  on a device pixel and drawn without anti-aliasing, so neighbours meet without seams.
- **`text`**: the same thing as text, for anyone who can't scan — the setup key, the UPI ID — in
  `code.md` under the tile, selectable so it can be copied.

A value longer than ``QeetrixQRCodeLevel/maximumByteCount`` (2,953 bytes at `l`, 1,273 at `h`) draws
an empty tile and logs an error; check it first.

### Accessibility

- VoiceOver reads `label` as an image: say what the code is for, not what it is ("QR code to pay Acme
  Traders by UPI"). Then it reads `text`. Give `text` for any code a person might need to enter by hand.
- The tile ignores Smart Invert, and is drawn the same in right to left: a QR code has no reading
  direction.
- The value is never logged. For a code that holds a secret, such as an authenticator's setup key, mark
  the view `privacySensitive()`.

### Platform differences

- **The text.** On the web the key or UPI ID is the product's own text beside the code, with a
  CopyButton. iOS takes it as `text` and makes it selectable; there's no CopyButton yet.
- **Too long a value.** The web throws a `RangeError`; a SwiftUI view can't, so iOS draws the empty tile.
- **Not CoreImage.** iOS's `CIQRCodeGenerator` chooses its own modes and masks, so its modules differ
  from the web's for the same value; Qeetrix doesn't use it.
- **Smart Invert** stands in for the web's forced colours, which the tile opts out of.

ui.qeet.in has no QRCode page yet; the component is specified in `07-components.md`.

## Topics

### Options

- ``QeetrixQRCodeLevel``
