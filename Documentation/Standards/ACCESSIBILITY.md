# Accessibility

Qeetrix targets WCAG 2.2 AA and Apple's platform accessibility expectations. Web patterns are
translated into native semantics, not copied: there is no ARIA on iOS. What a component announces,
how it scales and how it moves is decided with VoiceOver, Dynamic Type and the system's motion
settings in mind.

## What the foundations provide

| Need | Provided by | Automated check |
|:--|:--|:--|
| Text contrast (4.5:1) and non-text contrast (3:1) | Semantic colours; upstream's AA pairs re-measured on iOS values | `ContrastTests`, both themes |
| Light, dark, system appearance | `QeetrixColor`, `QeetrixThemeMode`, `.qeetrixTheme(_:)` | `ThemeTests` (rendered pixels), `ColorTests` |
| Dynamic Type | `.qeetrixTextStyle(_:)` scales with the role's text style; icons scale relative to `.body` | `TypographyTests`; showcase at accessibility sizes |
| Bold Text | `legibilityWeight == .bold` → one weight step up | `TypographyTests` |
| Reduce Motion | `.qeetrixAnimation(_:_:value:)`, `QeetrixMotion.animation(_:_:reduceMotion:)` → `motion.reduced.*` (no animation) | `MotionTests` |
| VoiceOver | `QeetrixIcon` is hidden when decorative, an image with a label when meaningful; elevation backgrounds are hidden | `IconTests` (semantics chosen) |
| Right-to-left | Directional icons mirror (`directionality: mirror` upstream); layout uses leading/trailing | `IconTests` (rendered mirror) |
| Touch targets | `QeetrixAccessibility.minimumTouchTarget` (44 pt), `.qeetrixMinimumTouchTarget()` | `TouchTargetTests` |
| Increased contrast | Read from the environment; no separate values exist upstream yet | `ColorTests` (falls back to standard) |

## What the components provide

| Need | How | Automated check |
|:--|:--|:--|
| 44 pt touch targets | `qeetrixHitArea()` extends the hit area without moving layout; a switch row is at least 44 pt tall | `ComponentFoundationTests`; UI tests tap outside a button's and a field's drawn frame |
| Native semantics | Native `Button`, `Toggle`, `TextField`, `ProgressView`; custom styles keep them through `accessibilityRepresentation` | UI tests find each as a button, switch, text field or progress indicator |
| Names | Icon-only buttons require a label; avatars read the name and the badge's status; spinners default to "Loading" | UI tests |
| State | Disabled from `disabled(_:)`; a busy button reports "Loading"; a selected card button is selected; a required field says "Required" | UI tests |
| Messages | A field's description and message are readable text after it, and a new message is announced | UI tests (text present); announcement posted in code |
| Dynamic Type and Bold Text | Every component's text is a role or a `QeetrixTypeSpec`; layouts wrap; avatar initials stay inside the avatar | AX3 snapshots of every component |
| Reduce Motion | Spinners and the busy indicator stand still; an indeterminate bar becomes a still hatch | Hatch snapshot and tests |
| Right-to-left | Leading/trailing layout; the switch thumb, progress sweep and avatar badge mirror; codes and numbers keep reading left to right | RTL snapshots of every component |
| Field association | The control carries its field: name = label (+ "Required"), hint = description, message as high-importance custom content; new messages announced | UI tests (names, readable messages); custom content and announcements are manual checks |
| Secure entry | Password: native `SecureField`, AutoFill content types, no autocorrection, reveal toggle named for its action; codes: one native one-time-code field | UI tests: a secure field never reports its text; reveal keeps keyboard and text; one code field, not cells |
| Selection | Checkbox: native toggle (system mixed state); radio: buttons with the selected trait; select: system menu | UI tests: toggles, mixed cycle, single selection, disabled options |
| Tabs | The strip has the tab-bar trait, each tab the selected trait; disabled tabs are dimmed and skipped; a wide strip scrolls instead of truncating | UI tests: tab bar, selection, disabled, scrolling |
| Overlays | Alerts, confirmation dialogs, sheets, popovers and menus are the system presentations, modal to VoiceOver; destructive actions carry the destructive role and always come with a cancel; sheet titles are headings and Close is labelled | UI tests: roles, cancel, guarded dismissal, Close, landscape popover |
| Toasts | Announced once (errors at high priority), not again for a repeat; a toast with an action stays while VoiceOver runs; VoiceOver focus or a pointer holds a toast past its time | Unit tests of the lifecycle; UI tests: replace, close, action, timeout |

## Rules for components

- Every interactive element has a hit area of at least 44 × 44 pt, an accessibility label, and the
  traits of what it is: button, header, selected, …
- Text uses a typography role or a component text style (`QeetrixTypeSpec`), never a fixed `Font`, so
  Dynamic Type and Bold Text apply. Layouts are tested at the accessibility sizes and reflow (stack,
  wrap) rather than truncate or overflow. The showcase uses `ViewThatFits` and a wrapping layout.
- Colour never carries meaning alone. Status pairs a colour with an icon or text.
- Motion goes through `qeetrixAnimation`. Nothing moves when Reduce Motion is on unless the movement
  carries meaning, and then it has a reduced alternative.
- Decorative images and icons are hidden from VoiceOver. Meaningful ones are labelled by what they
  mean ("Locked"), not what they show ("padlock").
- Use leading/trailing, never left/right. Icons with a direction come from the mirrored set.

## Verified on a device — still to do

The automated checks cover what can be measured in tests. These need a person with a device before a
component is called accessible:

- VoiceOver reading order, rotor headings and labels in context.
- Full Keyboard Access and Switch Control focus order.
- Dynamic Type at AX5 across real screens.
- Bold Text, Increased Contrast, Smart Invert and Differentiate Without Colour.
- The iOS 17 runtime itself. Everything compiles against iOS 17 but has been run on the iOS 27.1
  Simulator only.
- VoiceOver hearing a field message announcement, which a UI test cannot observe.
- VoiceOver reading a field's description (hint) and message (custom content) with the control, with
  hints on and off.
- Password AutoFill and one-time-code AutoFill from Messages, which need a device with saved passwords and
  a real text message.
- VoiceOver on a secure field, revealed and hidden: it must never read a hidden password.
- Full Keyboard Access through a form: focus order, the reveal toggle, steppers and radio options.
- VoiceOver hearing a toast announcement (errors interrupting, others queued), and the focus hold on a
  toast — a UI test can't move VoiceOver focus.
- VoiceOver on `QeetrixTabs`: "tab, n of m" in context, and the rotor.
- Full Keyboard Access in alerts, confirmation dialogs, sheets and menus, including Escape.
- Sheets and popovers on a real iPad, where they are a form sheet and an arrowed popover: the iPad
  simulator isn't installed here, so regular width was checked only through an iPhone in landscape.
