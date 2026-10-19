import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the Phase 3 pages of Sources/Qeetrix/Qeetrix.docc — Components/Field.md, FieldSet.md,
// Textarea.md, PasswordInput.md, OTPInput.md, Checkbox.md, RadioGroup.md, Select.md, NumberField.md,
// FormActions.md, FormErrorSummary.md and Forms.md — copied verbatim inside views that supply the names
// they use. iOS-only modifiers are guarded so the file also builds on the Mac host.

private enum Plan: Hashable { case starter, team }

private struct Channel: Identifiable {
    let id: String
    var isOn: Bool
}

/// Field.md, FieldSet.md, Textarea.md, Checkbox.md, RadioGroup.md and Select.md.
private struct ChoiceExamples: View {
    @State private var seats = 5
    @State private var email = true
    @State private var push = false
    @State private var feedback = ""
    @State private var accepted = false
    @State private var channels = [Channel(id: "Email", isOn: true), Channel(id: "Push", isOn: false)]
    @State private var plan = Plan.starter
    @State private var country: String? = nil
    let countries: [QeetrixOption<String?>] = [QeetrixOption("India", value: "IN")]

    var body: some View {
        VStack {
            QeetrixField("Seats", description: Text("You can add more later."), isRequired: true) {
                Stepper("\(seats) seats", value: $seats, in: 1...25)
            }
            QeetrixFieldSet("Notifications", description: Text("Choose how we reach you.")) {
                QeetrixCheckbox("Email", isOn: $email)
                QeetrixCheckbox("Push", isOn: $push)
            }
            QeetrixTextarea(
                "Feedback", text: $feedback,
                prompt: Text("What could be better?"),
                description: Text("Up to 500 characters.")
            )
            QeetrixCheckbox("Accept the terms", isOn: $accepted, description: Text("You can read them at any time."))
            QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
            QeetrixRadioGroup(
                "Plan", selection: $plan,
                options: [
                    QeetrixOption("Starter", value: Plan.starter),
                    QeetrixOption("Team", value: Plan.team, description: Text("Up to 25 members")),
                ])
            QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
        }
    }
}

/// PasswordInput.md, OTPInput.md, NumberField.md, FormActions.md and FormErrorSummary.md.
private struct EntryExamples: View {
    enum Field: Hashable { case email }

    @FocusState private var focus: Field?
    @State private var password = ""
    @State private var code = ""
    @State private var seats: Int? = 5
    @State private var discount: Decimal? = nil
    let isSubmitting = false

    var body: some View {
        VStack {
            QeetrixPasswordInput("Password", text: $password, purpose: .current, isRequired: true)
                .submitLabel(.go)
                .onSubmit(signIn)
            QeetrixOTPInput("Verification code", code: $code, groupSize: 3) { completed in
                verify(completed)
            }
            QeetrixNumberField("Seats", value: $seats, in: 1...250)
            QeetrixNumberField("Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1)
            QeetrixFormActions {
                QeetrixButton("Cancel", variant: .outline) { dismiss() }
                QeetrixButton("Create account", isLoading: isSubmitting) { submit() }
            }
            QeetrixFormErrorSummary(errors: [
                .init(id: "email", message: "Enter a valid email address.") { focus = .email }
            ])
        }
    }

    func signIn() {}
    func verify(_ code: String) {}
    func dismiss() {}
    func submit() {}
}

/// Forms.md, verbatim.
private struct SignUp: View {
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

@Suite("Form documentation examples")
struct FormDocumentationExamplesTests {
    @Test("Every Phase 3 example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ChoiceExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: EntryExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SignUp().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
