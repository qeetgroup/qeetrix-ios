# ``Qeetrix/QeetrixFormActions``

## Overview

A form's actions, end-aligned — tertiary first, then the primary or destructive one, 8 points apart:
the row `@qeetrix/react` uses in dialog, drawer and card footers.

```swift
QeetrixFormActions {
    QeetrixButton("Cancel", variant: .ghost, size: .lg) { dismiss() }
    QeetrixButton("Create account", size: .lg, isLoading: isSubmitting) { submit() }
}
```

When they don't fit on one line, the earlier actions wrap above.

### Accessibility

VoiceOver reads the actions in order, tertiary first.

### Platform differences

iOS only: at compact width the actions stack full width, the primary on top, and text buttons stretch to
the width — so a form's main button spans the column with its fields, as the web's `fullWidth` does on a
phone. The web has no separate component for the row.
