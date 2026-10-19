# ``Qeetrix/QeetrixRadioGroup``

## Overview

One choice from a few options that should all stay visible. For a long list use ``QeetrixSelect``;
for independent choices, ``QeetrixCheckbox``.

```swift
QeetrixRadioGroup(
    "Plan", selection: $plan,
    options: [
        QeetrixOption("Starter", value: Plan.starter),
        QeetrixOption("Team", value: Plan.team, description: Text("Up to 25 members")),
    ])
```

- **Selection.** Typed by the options' values: an option can only select a value the binding can hold.
  Exactly one is selected once chosen — choosing another moves the selection, choosing the selected one
  changes nothing. For "nothing chosen yet", make the selection optional (`Plan?`): a value no option has
  shows nothing selected.
- **Disabled options** are shown but cannot be chosen; `disabled(_:)` disables the group.
- **Validation.** A message under the group colours the discs' boundaries.

### Accessibility

Each option is a native button, a 44 pt row: VoiceOver reads its title, "Selected" on the chosen one, and
its description as the hint. The group is a container named by its label, and its message is read with
each option.

### Platform differences

The web radio group is one tab stop with arrow keys between options. On iOS a choice is a tap; with a
hardware keyboard each option is its own Full Keyboard Access stop.

On the web: [Radio Group on ui.qeet.in](https://ui.qeet.in/docs/components/radio-group).

## Topics

### Options

- ``QeetrixOption``
