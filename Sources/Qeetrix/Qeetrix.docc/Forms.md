# Forms

Build forms from the Qeetrix inputs and native SwiftUI: your state, your validation, Qeetrix's
presentation.

## Overview

Qeetrix provides the fields, their states and the way errors are shown — `@qeetrix/react`'s field
contract: a label above the control, help text or an error below it. It does not own a form's state,
validation, submission or persistence, and there is no form controller to adopt: a form is a SwiftUI
view with `@State` and `@FocusState`, laid out with stacks. A sign-up form is a welcoming page, so it
takes comfortable density (design rules §17):

```swift
struct SignUp: View {
    enum Field: Hashable { case email, password }

    @FocusState private var focus: Field?
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        VStack(alignment: .leading, spacing: density.spaceFormGap) {
            QeetrixFieldset("Your details") {
                QeetrixTextField("Work email", text: $email, prompt: Text("e.g. priya@acme.in"), error: emailError, isRequired: true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focus = .password }
                QeetrixPasswordInput("Password", text: $password, autoComplete: .newPassword, isRequired: true)
                    .focused($focus, equals: .password)
                    .submitLabel(.done)
            }
            QeetrixFormActions {
                QeetrixButton("Create account", size: .lg) { submit() }
            }
        }
        .qeetrixDensity(.comfortable)
    }

    func submit() {
        emailError = email.contains("@") ? nil : "Enter a work email, like priya@acme.in"
        if emailError != nil { focus = .email }
    }
}
```

### Who owns what

| Qeetrix | Your app |
|:--|:--|
| Labels, descriptions and the "(optional)" mark | The rules: what is valid, required or allowed |
| The invalid state and the error under the field | When to validate: as typed, on leaving a field, on submit |
| The error summary, and announcing errors to VoiceOver | Server-side validation and cross-field rules |
| Keyboard and AutoFill configuration of each input | Submission, authentication, persistence |

### Layout and wording

- **Fields** span their container and share one height (`size.control.lg`), so a form's fields, its
  alerts and its full-width button line up on both edges (design rules §8).
- **Labels** are short. Mark the fields that may be left empty with `isOptional` — never asterisks;
  `isRequired` tells VoiceOver only.
- **Prompts** show an example ("e.g. Acme Pvt Ltd"), never an instruction or the label. Put formats in
  the description ("15 characters").
- **Errors** say what to do ("Enter a work email"), not just what's wrong. An error replaces the
  field's description while it shows.
- **Spacing.** Fields stand the density's form gap (``QeetrixDensity/spaceFormGap``) apart. Group
  related fields in a ``QeetrixFieldset`` under a heading; a choice question is a ``QeetrixRadioGroup``
  (or checkboxes under their own question), not a fieldset.
- **Actions.** End the form with ``QeetrixFormActions``; the form's main button is `lg`, the field
  height.
- **The summary.** After a submit that fails validation, or when server errors arrive, show a
  ``QeetrixErrorSummary`` at the top, worded exactly as the fields' errors, and remove it once a submit
  succeeds.
- **Native forms.** In a settings screen built with SwiftUI's `Form` and `Section`, use the native rows
  and Qeetrix's styles (`.toggleStyle(.qeetrixSwitch)`) where they fit; the Qeetrix fields are designed
  for a scrolling stack.

### Focus and the keyboard

Every Qeetrix input accepts `focused(_:equals:)` from outside and passes it to its native field, so
`@FocusState` moves focus between them: set the next field in `onSubmit`, and focus the first invalid
field after a failed submit. Keyboard, content type, submit label and autocapitalisation modifiers apply
to the inputs as to any text field. In a `ScrollView`, SwiftUI keeps the focused field above the
keyboard; add `scrollDismissesKeyboard(_:)` to dismiss it by scrolling.

### Accessibility

Each input carries its field for VoiceOver: its label (with "Required"), its description as the hint,
and its error, read with it. A new error is announced, and so is a summary when it appears. Test a form
with VoiceOver on a device before calling it accessible — see <doc:Accessibility>.

## See Also

- ``QeetrixField``
- ``QeetrixFieldset``
- ``QeetrixFormActions``
- ``QeetrixErrorSummary``
