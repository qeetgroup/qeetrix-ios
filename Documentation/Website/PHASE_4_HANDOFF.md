# ui.qeet.in handoff: iOS navigation, overlays and feedback

For whoever maintains the component pages on ui.qeet.in (`qeetrix-docs`). It lists what Qeetrix for iOS
now provides for each web component, so a page can gain an **iOS** section. Nothing here has been
published: qeetrix-ios has no release, and nothing should be documented as installable until it does.

The source of truth for wording is the DocC catalogue in `Sources/Qeetrix/Qeetrix.docc`. The decisions
behind it are in ADR 0014.

## What to add, page by page

| ui.qeet.in page | iOS API | One-line summary for the page |
|:--|:--|:--|
| Tabs | `QeetrixTabs`, `QeetrixTab`, `QeetrixTabsVariant` | The same `default` and `line` variants. The app owns the selection and draws the panel. |
| Alert Dialog | `QeetrixAlertDialog`, `.qeetrixAlertDialog(_:)`, `QeetrixDialogAction` | The system alert, described as a value. A destructive action always comes with Cancel. |
| Dialog | `.qeetrixSheet(…)`, `QeetrixSheetContent` | On iPad, a centred form sheet. On iPhone, the bottom sheet takes the dialog's place. |
| Drawer | `.qeetrixSheet(…, detents:)`, `QeetrixSheetContent` | The iPhone bottom sheet, with detents and a grab handle. |
| Sheet | — | No iOS equivalent of the side panel. Say so. |
| Popover | `.qeetrixPopover(…)` | A system popover in regular width; a sheet on iPhone unless `.popover` is asked for. |
| Dropdown Menu | `QeetrixMenu`, `QeetrixMenuItem` | A Qeetrix button opening the system menu. Items take Qeetrix icons and roles. |
| Context Menu | `QeetrixMenuItem` in `.contextMenu` | The same items in the system context menu. |
| Toast | `QeetrixToast`, `.qeetrixToast(_:)` | The same types, icons and timing. One toast at a time, hosted per screen. |

Two iOS-only entries have no web page. They could go in an iOS overview page:

- **`QeetrixConfirmationDialog`**: the action sheet.
- **Navigation and tab bars**: `qeetrixNavigationBar(background:)`, `qeetrixTabBar()` and
  `qeetrixTabItem(_:icon:badge:)`.

## Examples to show

Use the examples from the DocC pages verbatim. Each one is compiled by
`Tests/QeetrixTests/Integration/OverlayDocumentationExamplesTests.swift`, so they stay correct. The
shortest, per page:

```swift
// Tabs
QeetrixTabs(selection: $section, tabs: [
    QeetrixTab("Overview", value: Section.overview),
    QeetrixTab("Activity", value: Section.activity, icon: .bell),
])

// Alert Dialog
alert = QeetrixAlertDialog(
    "Delete this workspace?",
    message: Text("Its projects and files are removed for everyone."),
    actions: [QeetrixDialogAction("Delete", role: .destructive) { deleteWorkspace() }])

// Toast
toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { unarchive() })
```

## Differences each page should state

Write each of these as a platform note, not as a limitation:

- **System-drawn surfaces.** iOS draws alerts, confirmation dialogs and menus in its own font and
  material. Only the tint is Qeetrix's.
- **State.** No overlay has a trigger component, and there is no global `toast()`. The app holds a
  value; setting it presents the overlay, and Qeetrix clears it when the overlay leaves.
- **Toasts.** One shows at a time. A new toast replaces the last, and a repeat isn't announced twice.
  While VoiceOver runs, a toast with an action stays until it is used.
- **Popover.** It becomes a sheet on iPhone portrait by default.
- **Missing iOS pieces.** There is no iOS snackbar (a toast with an action covers it), and the inline
  `Alert` is not yet available on iOS.

## Images

Don't take screenshots from the repository: snapshot baselines and screenshots are never committed
(ADR 0013). To make images for the site, run the showcase app (`Examples/QeetrixShowcase`) on a simulator
and capture the pages `tabs`, `app-navigation`, `alert-dialog`, `confirmation-dialog`, `sheet`,
`popover`, `menu`, `toast` and `overlay-patterns`. Launch with `-page <id>` to open one directly. Use the
synthetic content already on those pages; don't add real names or data.

## Verification status to quote

- **Verified on the iOS 27.1 iPhone simulator:** unit tests, snapshot comparisons and UI tests.
- **Not yet verified:**
  - VoiceOver speech on a device;
  - Full Keyboard Access;
  - an iPad (no iPad simulator is installed where this was built; regular width was checked through an
    iPhone in landscape);
  - an iOS 17 runtime.

Don't describe these as tested until they are.
