# ``Qeetrix/QeetrixSpinner``

## Overview

An indeterminate busy indicator: the `loader-circle` icon, turning once a second in the tertiary text
colour.

```swift
HStack {
    QeetrixSpinner()
    QeetrixSpinner(size: .lg, label: Text("Loading invoices"))
}
```

Sizes are `sm` 16 pt, `default` 20 pt, `lg` 24 pt and `xl` 32 pt. Inside a button, use the button's
`isLoading` instead, which reports the busy state on the button itself.

### Accessibility

- VoiceOver reads the label: "Loading" unless you give one. When a screen has more than one spinner,
  name what each is loading.
- With Reduce Motion on, the spinner stands still.

### Platform adaptations

The web spinner is a `role="status"` region. A new spinner is not announced on either platform; when
the wait matters, announce it from the screen that starts it.

The default label is localised from the package's strings (`Localizable.strings`), the counterpart of
the web's message catalogue.

On the web: [Spinner on ui.qeet.in](https://ui.qeet.in/docs/components/spinner).

## Topics

### Sizes

- ``QeetrixSpinnerSize``
