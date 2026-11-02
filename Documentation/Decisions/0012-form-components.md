# 0012 — Form components: one field, native inputs, the app's validation

**Status:** Accepted (Phase 3, 2026-10-18). Builds on ADR 0010. Amended by ADR 0015: fields take an `error` (no warning or success messages) and carry no asterisk.

## Context

Phase 3 adds the form controls: a field, a textarea, password, one-time-code and number inputs,
checkboxes, radio groups and a select, and the patterns that combine them. On the web, `Field` composes
any control with its label, description and messages, and associates them by element ids. Phase 2's
`QeetrixTextField` laid out its own label and message. Two input architectures, or a form framework, would
both be easy to drift into.

## Decision

1. **One field.** `QeetrixField` is the single implementation of the field layout — label (with the
   required asterisk or "(optional)"), control, description, message, 6 pt apart — and of its VoiceOver
   contract. Every Qeetrix input takes its label, description, message and required/optional flags and
   builds itself on it; `QeetrixTextField` was rebuilt on it with its look unchanged (its Phase 2
   snapshots still match) and gained `isOptional`. `QeetrixField` is public for any other control.
2. **The control carries the field.** iOS has no `aria-labelledby` or `aria-describedby`, so the field
   passes its parts to the control through the environment, and the control — the element VoiceOver
   focuses — carries them: its name is the label (plus "Required"), the description is its hint, and the
   message is attached as accessibility custom content at high importance, read with the control whatever
   the hints setting. The description and message are also text in reading order, as on the web, and a
   new message is announced. A group's message (a fieldset, a radio group) is attached to each checkbox
   and radio in the group; fields in a fieldset carry their own messages.
3. **Native controls are the authority.** Each input is the system control, styled:
   - password: `SecureField` (and, revealed, a `TextField` on the same binding), with Password AutoFill
     content types;
   - one-time code: one `TextField` with `.oneTimeCode`, drawn as cells — never a field per cell, which
     would break paste, AutoFill and VoiceOver;
   - textarea: a vertical-axis `TextField`, which grows and then scrolls;
   - checkbox: `Toggle`, including `Toggle(sources:isOn:)` for the mixed state, with a `ToggleStyle`;
   - radio: a `Button` per option with the selected trait (SwiftUI offers no radio control and no custom
     `PickerStyle`);
   - select: a `Menu` of `Toggle` items — a menu draws them with a checkmark and honours `disabled`, which
     it ignores on `Picker` rows;
   - number: a `TextField` with its own editing text, Foundation formatting and a strict `Decimal` reader.
4. **Typed choices.** `QeetrixOption<Value>` serves the radio group and the select; the selection is a
   `Binding<Value>`, so an option can only select a value the binding can hold. "Nothing selected" is a
   value no option has — an optional `Value` and `nil` — not a separate API.
5. **The app validates.** Qeetrix presents messages; apps decide them. There is no validation engine,
   form model or form controller. Focus is the app's `@FocusState`: every input accepts
   `focused(_:equals:)` from outside (verified by UI tests).
6. **Numbers are exact and forgiving.** Values are `Int?` or `Decimal?`. The text being typed is kept apart
   from the value, so in-between states (a minus, a trailing separator) are never rejected; committing
   clamps to the range and rounds. Reading is strict — Foundation's lenient parser accepts "12abc" as 12
   and, in German, "1234.5" as 1234 — and accepts any script's decimal digits.
7. **Secrets stay in the binding.** Password and code inputs keep no copy of the text, never log or
   describe it, and are marked `privacySensitive()`. Tests and snapshots use synthetic values only.
8. **Composition only where it adds behaviour.** `QeetrixFieldSet` (legend, group message, row spacing),
   `QeetrixFormActions` (the web's stacked-or-row placement, full-width buttons on compact width) and
   `QeetrixFormErrorSummary` (the alert surface, announcement and focus links) are components; a form
   container is not — a `VStack` and the density's field gap express it.
9. **Touch targets.** Checkbox, radio and switch rows are at least 44 pt tall and sit flush, instead of the
   web's 16 pt control with a 24 px pointer target and 12 px gaps. Error-summary links are full 44 pt
   rows: a UI test showed extended hit areas on links 4 pt apart sending a tap to the neighbouring link.

## Consequences

- One field implementation to keep right, and every input reads the same.
- Some web behaviour has a platform counterpart instead of a copy — the select's system menu, the radio
  group's per-option focus, the number field's steppers without scrubbing — and each component page lists
  them under *Platform differences*.
- VoiceOver speech itself (custom content, announcements) cannot be asserted by automated tests; it is on
  the manual checklist in `Documentation/Standards/ACCESSIBILITY.md`.
