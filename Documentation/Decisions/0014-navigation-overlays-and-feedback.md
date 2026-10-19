# 0014 — Navigation, overlays and feedback: native presentation, state owned by the app

**Status:** Accepted (Phase 4, 2026-10-19). Builds on ADRs 0010 and 0011.

## Context

Phase 4 adds the components that move people around an app and interrupt them: tabs, the navigation and
tab bars, alerts, confirmation dialogs, sheets, popovers, menus and toasts.

On the web, these components are built by Qeetrix itself:

- `Dialog`, `AlertDialog`, `Drawer` and `Sheet` are portals with a scrim and a focus trap.
- `DropdownMenu` and `ContextMenu` are positioned layers.
- `Toast` is a global `toast()` function that feeds a `Toaster` mounted once.

iOS already has all of these, and they are what VoiceOver, Full Keyboard Access, the gestures and iPad
adaptation are built around.

Phase 4 could go wrong in two directions:

- **Rebuilding the machinery.** A custom overlay layer, a router, or a global modal or toast manager would
  have to re-implement every one of those behaviours, and would drift from the system.
- **Exposing the bare system modifiers.** Products would then share no contract: no tokens, no roles, no
  rules for dismissal.

## Decision

1. **Native presentation.** Each component wraps the SwiftUI presentation it stands for:

   | Component | SwiftUI presentation |
   |:--|:--|
   | `qeetrixAlertDialog` | `.alert` |
   | `qeetrixConfirmationDialog` | `.confirmationDialog` |
   | `qeetrixSheet` | `.sheet` |
   | `qeetrixPopover` | `.popover` |
   | `QeetrixMenu` | `Menu` (its items also work in `contextMenu`) |
   | the tab bar helpers | `TabView` |
   | the navigation bar helper | the bar of a `NavigationStack` |

   Qeetrix styles what the platform lets an app style:

   - the tint;
   - the sheet and popover background and corner, from the `component.dialog` and `component.popover`
     tokens (adopted per ADR 0011);
   - trigger buttons;
   - icons, through `Image(qeetrix:)`.

   The alert, the confirmation dialog and the menu are drawn by iOS in its own fonts and materials. The
   docs say so rather than imitating them.

   There is no custom modal layer, no router, no modal manager and no singleton.
2. **The app owns the state.** Each presentation is one binding, owned by the view that presents it:
   either an optional value (a dialog, an item sheet, a toast) or a `Bool`. Qeetrix sets it back to `nil`
   or `false` however the presentation ends, so the binding and the screen never disagree. Navigation
   paths and selected tabs are the app's too: `QeetrixTabs` and `TabView` take a selection binding, and
   Qeetrix keeps no navigation state.
3. **Dialogs are values.**
   - `QeetrixAlertDialog` and `QeetrixConfirmationDialog` hold a title, an optional message and
     `QeetrixDialogAction`s, which carry the system `ButtonRole`. Presenting means setting the value.
   - A tap clears the value first, then runs the action exactly once. That way the action sees the dialog
     gone and may present another.
   - A dialog whose actions include a destructive one but no cancel gets a "Cancel" action, so the safe
     choice is always there.
   - A confirmation records a person's intent; it does not authorise anything. Whoever performs the action
     still decides whether it is allowed.
4. **Names follow the web where the meanings match.** The web's `Alert` is an inline status message, and
   its modal is `AlertDialog`. The iOS modal is therefore `QeetrixAlertDialog`, which keeps the name
   `QeetrixAlert` free for the inline component in a later phase. `QeetrixConfirmationDialog` has no web
   counterpart: it is iOS's action sheet, used where the web would use an `AlertDialog` or a
   `DropdownMenu`.
5. **One sheet; no separate `QeetrixDialog`.**
   - `qeetrixSheet(isPresented:detents:isDismissDisabled:onDismiss:content:)` stands for two web
     components. On iPhone it is the web `Drawer`: a bottom sheet with detents and a grab handle. On iPad
     it is the web `Dialog`: a centred form sheet.
   - `QeetrixSheetContent` provides the web Dialog's parts: a heading title, a description, Close, the
     scrolling body and pinned actions.
   - **A separate centred dialog is deferred.** On iPhone it would duplicate the sheet with weaker
     accessibility and gestures, and on iPad the sheet already is one. If a product needs a centred modal
     that is not a sheet, this decision is revisited.
6. **Dismissal is guarded in the app.** `isDismissDisabled` stops a swipe or a tap outside from dismissing
   the sheet; the app decides when. Close in `QeetrixSheetContent` takes an `onClose` closure, so a sheet
   with unsaved changes can ask before discarding them. SwiftUI reports no attempted swipe, so the swipe
   is simply refused.
7. **Popover.** It is the system popover. In compact width it adapts to a sheet by default, the native
   form on a phone; `compactAdaptation: .popover` keeps it small.
8. **Menu.**
   - The trigger is a Qeetrix button: a variant and size, with a title and a chevron, or an icon with a
     label.
   - `QeetrixMenuItem` gives items a Qeetrix icon and a role. Dividers, sections and pickers are the
     native views.
   - The `component.menu` tokens are not adopted, because the system draws the menu surface.
9. **Toast: a host per view, one at a time.**
   - `.qeetrixToast($toast)` hosts toasts for the view it modifies. It replaces the web's global `toast()`
     and `Toaster`; there is no app-wide service.
   - One toast is visible at a time. A new toast replaces the current one at once, and nothing queues. The
     web stacks toasts up to a limit; on a phone a stack covers the content, and VoiceOver would announce
     every toast in it.
   - A repeat of the toast on screen (the same type, title and description) keeps the toast and restarts
     its timer. It is not announced again.
   - Timing follows the web: 5 s, or 10 s for warnings, errors and toasts with an action; `.zero` keeps a
     toast until it is dismissed.
     - While VoiceOver is running, a toast with an action stays until it is used or closed, so the time
       limit can't take the action away (WCAG 2.2.1).
     - A toast whose time runs out while VoiceOver's focus or a pointer is on it leaves when they move off.
   - Each new toast is announced once, errors at high priority.
   - The lifecycle is a value type, `QeetrixToastState`, unit-tested apart from the view. The timer is a
     `.task(id:)`, so it is cancelled when the toast changes or the view disappears; no task outlives its
     view.
   - The title and description are plain localised strings, because they are also announced. The docs
     forbid secrets in them.
10. **No snackbar.** The web has no snackbar. A toast with an action covers what the Material snackbar
    does, so `QeetrixSnackbar` is deferred until a product shows a need the toast doesn't meet.
11. **Navigation chrome is styled, not replaced.**
    - There is no `QeetrixNavigationBar` view. Instead there are modifiers:
      - `qeetrixNavigationBar(background:)` sets the brand tint and, optionally, the canvas background;
      - `qeetrixTabBar()` sets the brand tint;
      - `qeetrixTabItem(_:icon:badge:)` makes a tab with a Qeetrix icon.
    - The bars, back navigation, large titles and the iPad sidebar adaptation stay the system's.
    - `Image(qeetrix:)` renders a Qeetrix icon into a template image for chrome that accepts only images.
      The system sizes those images. They don't mirror in right-to-left layouts, so chrome should avoid
      the directional icons.
    - On UIKit that image is a `UIImage`. A UI test found that a system menu item whose image was a bare
      `CGImage` lost its accessibility: the item was drawn correctly but reached VoiceOver without its
      title.
12. **In-content tabs are Qeetrix-drawn.** `QeetrixTabs` draws the web's `default` and `line` variants:
    - the strip carries the tab-bar trait, and each tab its selected state;
    - a strip wider than its container scrolls, and keeps the selection in view;
    - labels never truncate.

## Consequences

- Alerts, confirmation dialogs, menus and sheets behave exactly as iOS users expect, including VoiceOver
  focus, Escape and Return, swipe dismissal and iPad adaptation. In exchange, Qeetrix can't restyle the
  surfaces the system draws.
- Tests follow that split:
  - Snapshots cover only what Qeetrix draws: tabs, the sheet layout, the popover surface, menu triggers
    and toasts.
  - UI tests cover presentation and dismissal, roles, exactly-once actions, guarded dismissal, adaptation
    in landscape, and the toast lifecycle.
  - Unit tests cover the dialog action rules and the toast state machine.
- Products build their own navigation and present their own overlays, which keeps business rules out of
  the design system. In exchange, the same few lines of state appear in every app; the showcase's overlay
  patterns page shows the idiom.
- A centred non-sheet dialog, a snackbar, an inline `QeetrixAlert` and a styled menu surface are open
  questions, recorded in `PHASES.md`.
