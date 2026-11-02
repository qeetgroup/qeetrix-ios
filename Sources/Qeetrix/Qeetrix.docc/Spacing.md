# Spacing

Lay out views on the Qeetrix spacing scale: inside containers, between siblings, between sections.

## Overview

``QeetrixSpace`` is `@qeetrix/tokens`' spacing, on a 4-point grid, in three sets:

| Set | `xs` | `sm` | `md` | `lg` | `xl` | Use |
|:--|--:|--:|--:|--:|--:|:--|
| `inset` | 4 | 8 | 12 | 16 | 24 | Padding inside a container (``QeetrixSpace/insetLg``) |
| `gap` | 4 | 8 | 12 | 16 | 24 | Space between siblings (``QeetrixSpace/gapSm``) |
| `layout` | — | 24 | 32 | 48 | 64 | Space between sections (``QeetrixSpace/layoutLg``) |

Use them for padding, stack spacing and gaps, instead of literal numbers:

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
    Text("Title").qeetrixTextStyle(.headingSm)
    Text("Body").qeetrixTextStyle(.bodyMd)
}
.padding(QeetrixSpace.insetLg)
```

## The form gap

Fields in a form stand ``QeetrixDensity/spaceFormGap`` apart — 12, 16 or 20 points at compact, default
and comfortable density — so a denser region tightens its forms with its controls.
``QeetrixFieldset`` uses it; read it from the environment for your own stacks:

```swift
struct ContactForm: View {
    @Environment(\.qeetrixDensity) private var density
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: density.spaceFormGap) {
            QeetrixTextField("Name", text: $name)
            QeetrixTextField("Email", text: $email)
        }
    }
}
```

The names are the token paths in lowerCamelCase: `space.inset.lg` is `insetLg`.
