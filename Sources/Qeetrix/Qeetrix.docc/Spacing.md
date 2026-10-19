# Spacing

Lay out views on the Qeetrix spacing scale.

## Overview

``QeetrixSpacing`` is the spacing scale, in points:

| Token | Points |
|:--|--:|
| ``QeetrixSpacing/zero`` | 0 |
| ``QeetrixSpacing/xxs`` | 2 |
| ``QeetrixSpacing/xs`` | 4 |
| ``QeetrixSpacing/s`` | 8 |
| ``QeetrixSpacing/m`` | 12 |
| ``QeetrixSpacing/l`` | 16 |
| ``QeetrixSpacing/xl`` | 24 |
| ``QeetrixSpacing/xl2`` | 32 |
| ``QeetrixSpacing/xl3`` | 48 |
| ``QeetrixSpacing/xl4`` | 64 |
| ``QeetrixSpacing/xl5`` | 96 |

Use it for padding, stack spacing and gaps, instead of literal numbers:

```swift
VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
    Text("Title").qeetrixTextStyle(.heading)
    Text("Body").qeetrixTextStyle(.body)
}
.padding(QeetrixSpacing.l)
```

The names follow the web's `space.*` tokens. A leading number moves to the end, because Swift names
can't start with a digit: `space.2xl` is `xl2`.
