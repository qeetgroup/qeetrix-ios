# Forms

Build forms from the Qeetrix inputs and native SwiftUI: your state, your validation, Qeetrix's
presentation.

## Overview

Qeetrix provides the fields, their states and the way errors are shown. It does not own a form's state,
validation, submission or persistence, and there is no form controller to adopt: a form is a SwiftUI view
with `@State` and `@FocusState`, laid out with stacks.

```swift
struct SignUp: View {
    enum Field: Hashable { case email, password }

    @FocusState private var focus: Field?
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixDensity.default.fieldGap * 1.5) {
            QeetrixFieldSet("Your details") {
                QeetrixTextField(
                    "Work email", text: $email,
                    message: emailError.map { QeetrixFieldMessage(.error, text: $0) }, isRequired: true
                )
                .focused($focus, equals: .email)
                .submitLabel(.next)
                .onSubmit { focus = .password }
                QeetrixPasswordInput("Password", text: $password, purpose: .new, isRequired: true)
                    .focused($focus, equals: .password)
                    .submitLabel(.done)
            }
            QeetrixFormActions {
                QeetrixButton("Create account") { submit() }
            }
        }
    }

    func submit() {
        emailError = email.contains("@") ? nil : "Enter an email address with an @."
        if emailError != nil { focus = .email }
    }
}
```

### Who owns what

| Qeetrix | Your app |
|:--|:--|
| Labels, descriptions, required and optional marks | The rules: what is valid, required or allowed |
| Error, warning and success presentation, and their colours | When to validate: as typed, on leaving a field, on submit |
| Announcing a new message to VoiceOver | Server-side validation and cross-field rules |
| Keyboard and AutoFill configuration of each input | Submission, authentication, persistence |

### Layout

- **Sections.** Group related fields in a ``QeetrixFieldSet``, and space sections one and a half field
  gaps apart (`qeetrixDensity(_:)` gives the gap), as the web's `Form` does.
- **Actions.** End the form with ``QeetrixFormActions``.
- **Errors.** After a failed submit, show the field messages and, on a long form, a
  ``QeetrixFormErrorSummary`` at the top.
- **Native forms.** In a settings screen built with SwiftUI's `Form` and `Section`, use the native rows
  and Qeetrix's styles (`.toggleStyle(.qeetrixSwitch())`) where they fit; the Qeetrix fields are designed
  for a scrolling stack.

### Focus and the keyboard

Every Qeetrix input accepts `focused(_:equals:)` from outside and passes it to its native field, so
`@FocusState` moves focus between them: set the next field in `onSubmit`, and focus the first invalid
field after a failed submit. Keyboard, content type, submit label and autocapitalisation modifiers apply
to the inputs as to any text field. In a `ScrollView`, SwiftUI keeps the focused field above the
keyboard; add `scrollDismissesKeyboard(_:)` to dismiss it by scrolling.

### Accessibility

Each input carries its field for VoiceOver: its label (with "Required"), its description as the hint, and
its message, read with it. New messages are announced. Test a form with VoiceOver on a device before
calling it accessible — see <doc:Accessibility>.

## See Also

- ``QeetrixField``
- ``QeetrixFieldSet``
- ``QeetrixFieldMessage``
- ``QeetrixFormActions``
- ``QeetrixFormErrorSummary``
