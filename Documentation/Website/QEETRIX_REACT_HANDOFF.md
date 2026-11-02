# ui.qeet.in handoff: Qeetrix for iOS, by `@qeetrix/react` component

For whoever maintains the component pages on ui.qeet.in (`qeetrix-docs`). Qeetrix for iOS now follows
`@qeetrix/react` 0.4.0, `@qeetrix/tokens` 0.0.13 and `@qeetrix/icons` 2.1.0 (ADR 0015), so each page can
gain an **iOS** section under the same name. Nothing here is published: qeetrix-ios has no release, and
nothing should be documented as installable until it does.

The source of truth for wording is the DocC catalogue in `Sources/Qeetrix/Qeetrix.docc`, which links
each component to its ui.qeet.in page. The old-to-new API map is in
[MIGRATION_QEETRIX_REACT.md](../MIGRATION_QEETRIX_REACT.md). This replaces the Phase 4 handoff, which
used `@qeetrix/ui`'s names.

## What to add, page by page

| ui.qeet.in page (`/components/<slug>/`) | iOS API | One-line summary for the page |
|:--|:--|:--|
| `button` | `QeetrixButton`, `QeetrixButtonStyle` (`.qeetrix(_:tone:size:)`) | The same `variant` (solid, soft, ghost), `tone` (brand, danger, neutral) and `size` (sm, md, lg), label first with the icon in its zone. Any SwiftUI button or link can take the style. |
| `icon-button` | `QeetrixIconButton` | Square, the label required; it shows as a tooltip under an iPad pointer. |
| `badge` | `QeetrixBadge` | The same tones, `subtle` and `solid`, `sm` and `md`. |
| `card` | `QeetrixCard`, `QeetrixCardButtonStyle` | The ruled card with its title, description, actions and footer, `default` or `subdued`, `neutral` or `danger`. iOS adds a selectable card style. |
| `avatar` | `QeetrixAvatar` | The same sizes and shapes, initials and legal-form rule. |
| `separator` | `QeetrixSeparator` | The same tones, horizontal or vertical. |
| `spinner` | `QeetrixSpinner` | The same ring, sizes and tones; it fades under Reduce Motion. |
| `progress` | `QeetrixProgress`, `QeetrixProgressViewStyle` | The same track and tones; any `ProgressView` can take the style. |
| `text` | `QeetrixText` | The body roles' sizes and weights, the text tones, `mono`, `truncate`. |
| `heading` | `QeetrixHeading` | `level` sets the outline (VoiceOver's heading levels), `size` the look. |
| `input` | `QeetrixField`, `QeetrixTextField` (`icon`, `startAdornment`, `endAdornment`) | The filled field: label, control, then the description or the error that replaces it. |
| `text-field` | `QeetrixTextField` | Field and input in one, on SwiftUI's `TextField`. |
| `textarea` | `QeetrixTextarea` | `rows` and `maxRows`; it grows, then scrolls. |
| `form` | `QeetrixFieldset`, `QeetrixErrorSummary`, `QeetrixFormActions` | The fieldset, the error summary ("Fix these to continue") and the actions row. iOS validation is the app's. |
| `password-input` | `QeetrixPasswordInput` | AutoFill per `autoComplete`; the Show password toggle. |
| `otp-input` | `QeetrixOTPInput` | `length`, `groups`, `size`, `validationType`; one native field drawn as slots, so paste and SMS AutoFill work. |
| `number-field` | `QeetrixNumberField` | `Int` or exact `Decimal` values, affixes, the steppers. |
| `select` | `QeetrixSelect` | The field-look trigger opening the system menu. |
| `checkbox` | `QeetrixCheckbox`, `QeetrixCheckboxToggleStyle` | On SwiftUI's `Toggle`, including the mixed state of a parent checkbox. |
| `radio` | `QeetrixRadioGroup` | Vertical or horizontal; one button per option, selected or not. |
| `switch` | `QeetrixSwitch`, `QeetrixSwitchToggleStyle` | On SwiftUI's `Toggle`: the square track, the control first, then the label. |
| `tabs` | `QeetrixTabs`, `QeetrixTab` | `line` and `contained`, the sliding Ember bar, icons that fill when selected, counts. |
| `dialog` | `QeetrixAlertDialog`, `QeetrixConfirmationDialog`, `.qeetrixSheet` with `QeetrixSheetContent(intent:)` | Short decisions are the system alert or action sheet; a dialog with content is a sheet with the dialog's intent line. |
| `drawer` | `.qeetrixSheet`, `QeetrixSheetContent` | The system sheet with the drawer's ruled header, body and footer. |
| `popover` | `.qeetrixPopover(isPresented:title:description:)` | The system popover in regular width; a sheet on iPhone unless `.popover` is asked for. |
| `menu`, `context-menu` | `QeetrixMenu`, `QeetrixMenuItem` (in a menu or `.contextMenu`) | A Qeetrix button opening the system menu; items take Qeetrix icons, a description and the danger tone. |
| `toast` | `QeetrixToast`, `.qeetrixToast(_:)` | The same tones, icons, status edge and timing; one at a time, hosted per screen. |

Two iOS-only entries have no web page. They could go in an iOS overview page:

- **Navigation and tab bars**: `qeetrixNavigationBar(background:)`, `qeetrixTabBar()` and
  `qeetrixTabItem(_:icon:badge:)`.
- **The selectable card**: `.buttonStyle(.qeetrixCard(isSelected:))`.

## Examples to show

Use the examples from the DocC pages verbatim. Each is compiled and rendered by a test in
`Tests/QeetrixTests/Integration/*DocumentationExamplesTests.swift`, so they stay correct. The shortest:

```swift
// Button
QeetrixButton("Export", icon: .share2, variant: .soft) { export() }

// Text field
QeetrixTextField("Trade name", text: $tradeName, prompt: Text("e.g. Acme Pvt Ltd"), isOptional: true)

// Tabs
QeetrixTabs(selection: $section, tabs: [
    QeetrixTab("Overview", value: Section.overview),
    QeetrixTab("Activity", value: Section.activity, icon: .bell, filledWhenSelected: true, badge: 3),
])

// Toast
toast = QeetrixToast(.danger, title: "Report not sent", description: "Check your connection.")
```

## Differences each page should state

Write each of these as a platform note, not as a limitation:

- **Touch targets.** Every control has a 44 pt touch target; checkbox, radio and switch rows are 44 pt
  tall.
- **Dynamic Type and Bold Text.** Text scales with the reader's text size, and controls with it: at
  the default size a control is the web's height, above it the box, icon buttons and icon zones grow
  in proportion and button labels wrap. Bold Text raises the weight.
- **System-drawn surfaces.** iOS draws alerts, action sheets, sheets, popovers (with their arrow) and
  menus in its own material and font. Qeetrix supplies the content, the triggers and the tint, so a
  menu has no Ember highlight edge or shortcuts and a select's list is the system menu.
- **State.** No overlay has a trigger component, and there is no global `toast()`. The app holds a
  value; setting it presents the overlay, and Qeetrix clears it when the overlay leaves.
- **Toasts.** One shows at a time; a new toast replaces the last. While VoiceOver runs, a toast with an
  action stays until it is used.
- **Fields.** No Caps Lock warning in the password field (iOS has no reliable signal for it), no
  field help ⓘ yet.
- **Not on iOS yet.** Alert, Tooltip (an icon button's `.help` covers the pointer case), Link, Toggle,
  Slider, Accordion, Table, Meter and the experimental components.

## Images

Don't take screenshots from the repository: snapshot baselines and screenshots are never committed
(ADR 0013). To make images for the site, run the showcase app (`Examples/QeetrixShowcase`) on a simulator
and launch a page directly with `-page <id>`. Use the synthetic content already on those pages; don't
add real names or data.

## Verification status to quote

- **Verified on simulators:** unit tests, snapshot comparisons (iOS 27.1) and UI tests (iOS 27.1, and
  the iOS 26.5 iPhone and iPad models listed in the migration report).
- **Not yet verified:** VoiceOver speech on a device; Full Keyboard Access focus order; an iOS 17
  runtime (the package compiles for it).

Don't describe these as tested until they are.
