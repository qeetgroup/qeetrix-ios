# ``Qeetrix/QeetrixSteps``

## Overview

Where a person is in a flow of a few steps — set up an account, add a passkey, connect a directory —
as `@qeetrix/react`'s Steps.

```swift
QeetrixSteps([QeetrixStep("Account"), QeetrixStep("Phone"), QeetrixStep("Passkey")], current: 1)
```

- **Markers**: 24-point squares with 4-point corners. Done steps are filled Ember with a tick, the
  current one has a 2-point Ember outline round its number, those to come a 1-point
  `color.border.strong` outline round a subtle number. A step's `status` can say what `current` can't:
  `failed` (`color.bg.danger.bold` with a cross), `attention` (`color.bg.warning.bold` with a warning
  sign), or `done` for a later step that stays done.
- **Labels**: `body.md`; the current one at weight 600, those to come in `color.text.subtle`.
- **Across the screen** (`horizontal`, the default): equal columns, each label centred under its
  marker, with a 1-point line between the markers that turns Ember behind the done steps.
- **Compact**: where the labels don't all fit on one line in their columns — a narrow screen, many
  steps, the largest text sizes — the current step's marker and label under "Step 2 of 4", over a
  4-point bar filled as far as the steps done.
- **Vertical**: each label beside its marker, its first line centred on it, with its description
  under it and a line down to the next step.
- `current` is the current step's index from 0, or the number of steps once every step is done.

```swift
QeetrixSteps(
    [
        QeetrixStep("Connect the directory", description: "Okta, over SAML"),
        QeetrixStep("Map attributes", description: "Email and name"),
        QeetrixStep("Test a sign-in", status: .failed),
        QeetrixStep("Go live"),
    ],
    current: 2, orientation: .vertical)
```

With `onStepSelect`, done steps are buttons back to themselves; steps ahead never are:

```swift
QeetrixSteps(setup, current: current) { index in current = index }
```

### Accessibility

- VoiceOver reads every step, in each form, with its position and its state: "Verify phone, Step 2 of
  4, Current step"; "Account, Step 1 of 4, Completed"; a vertical step's description follows. The
  list is named "Progress". In the compact form the steps not shown are still read.
- A selectable done step is a button with a 44-point touch target, and shows the focus frame with Full
  Keyboard Access.
- Labels never truncate: across the screen they fit on one line or the compact form takes over;
  vertically and in the compact form they wrap. The markers grow with Dynamic Type. In right-to-left
  layouts the steps run from the right and the bar fills from the right.

### Platform differences

- **The compact form.** Under 24rem the web keeps every marker and shows only the current step's label.
  A phone is narrower than that, so iOS shows the current step, "Step 2 of 4" and a bar instead.
- **Positions.** The web's ordered list gives each step its position; iOS says it in words — "Step 2
  of 4" — and "Current step" where the web uses `aria-current="step"`.

On the web: [Steps on ui.qeet.in](https://ui.qeet.in/components/steps/).

## Topics

### Steps

- ``QeetrixStep``
- ``QeetrixStepStatus``
- ``QeetrixStepsOrientation``
