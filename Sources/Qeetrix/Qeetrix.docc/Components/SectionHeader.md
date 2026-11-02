# ``Qeetrix/QeetrixSectionHeader``

## Overview

The label of a group of rows — Qeetrix's group label: small, tracked capitals in
`typography.label.caps` (11 / 16 points, weight 600, +6 %) and `color.text.subtlest`, under a 1-point
`color.border.subtle` rule, as the web Sidebar labels its groups. `label.caps` is Qeetrix's one
uppercase role (design rules §5).

```swift
List {
    Section {
        QeetrixListItem("Face ID", isOn: $faceID)
    } header: {
        QeetrixSectionHeader("Security", isRuled: false)
    }
    .listSectionSeparator(.hidden)
    Section {
        ForEach(devices) { device in
            QeetrixListItem(device.name, description: Text(device.lastSeen))
        }
    } header: {
        QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use.")) {
            QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) { signOutAll() }
        }
    }
    .listSectionSeparator(.hidden)
}
.qeetrixListStyle()
```

- **Anatomy**, from sidebar.css's `.qx-sidebar-group-label`: `space.gap.sm` and the rule above the
  label, `space.inset.md` from the rule to the label, 6 points from the label to the rows, and the rows'
  16-point inset at the sides. The rule runs edge to edge.
- **`isRuled: false`** for a list's first group, as the Sidebar's first group has no rule.
- **Description**: a sentence under the label in `body.sm`, `color.text.subtle`, as written — not
  capitalised.
- **Action**: at the header's end, an action on the whole group — typically a ghost ``QeetrixButton``.

Above a group of rows in a stack it is the same view:

```swift
VStack(spacing: 0) {
    QeetrixSectionHeader("Recovery codes", isRuled: false)
    QeetrixListItem("Download codes", accessory: .chevron) { download() }
}
```

### Accessibility

- **Write the title in sentence case** ("Signed-in devices"): the capitals are styling, so VoiceOver
  reads the words as written, not letter by letter.
- The title and the description are read as one heading, so the rotor's headings move from group to
  group. The action is its own control.
- **Indic text** has no capitals and renders as written, without the tracking, so conjuncts stay
  intact: sidebar.css drops it for Hindi, Marathi, Bengali, Gujarati, Punjabi, Odia, Tamil, Telugu,
  Kannada and Malayalam. iOS drops it in those languages and, for a title shown as given, whenever the
  title itself is in an Indic script.
- The label and the description wrap at large text sizes.

### Platform differences

- **iOS's own.** `@qeetrix/react` has no section header for rows (a web screen groups a Sidebar with
  SidebarGroup and a Table with column groups), so this follows qeetrix-android's
  `QeetrixSectionHeader`, drawn as the Sidebar's group label; Android's `ruled` is `isRuled`.
- **In a `List`** it sets its own insets and turns off the list's header capitals, so only the label
  is capitalised. A plain list's header stays pinned while its rows scroll under it: give it the surface
  it sits on with `background(_:)`.
