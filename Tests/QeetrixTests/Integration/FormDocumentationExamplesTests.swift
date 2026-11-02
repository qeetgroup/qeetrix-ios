import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the form pages of Sources/Qeetrix/Qeetrix.docc — Components/Field.md, Fieldset.md,
// Textarea.md, PasswordInput.md, OTPInput.md, Checkbox.md, RadioGroup.md, Select.md, NumberField.md,
// FormActions.md, ErrorSummary.md and Forms.md — copied verbatim inside views that supply the names
// they use. iOS-only modifiers are guarded so the file also builds on the Mac host.

private enum Plan: Hashable { case monthly, yearly }

private struct Channel: Identifiable {
    let id: String
    var isOn: Bool
}

/// Field.md, Fieldset.md, Textarea.md, Checkbox.md, RadioGroup.md and Select.md.
private struct ChoiceExamples: View {
    @State private var seats = 5
    @State private var street = ""
    @State private var city = ""
    @State private var notes = ""
    @State private var receipts = true
    @State private var channels = [Channel(id: "Email", isOn: true), Channel(id: "SMS", isOn: false)]
    @State private var cycle = Plan.monthly
    @State private var country: String? = nil
    let countries: [QeetrixOption<String?>] = [QeetrixOption("India", value: "IN"), QeetrixOption("Nepal", value: "NP")]

    var body: some View {
        VStack {
            QeetrixField("Seats", description: Text("You can add more later.")) {
                Stepper("\(seats) seats", value: $seats, in: 1...25)
            }
            QeetrixFieldset("Billing address", description: Text("Where invoices are sent.")) {
                QeetrixTextField("Street", text: $street)
                QeetrixTextField("City", text: $city)
            }
            QeetrixTextarea("Notes", text: $notes, prompt: Text("e.g. Deliver after 5 pm"), rows: 4)
            QeetrixCheckbox("Email me receipts", isOn: $receipts, description: Text("One email per invoice."))
            QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
            QeetrixRadioGroup(
                "Billing cycle", selection: $cycle,
                options: [
                    QeetrixOption("Monthly", value: Plan.monthly),
                    QeetrixOption("Yearly", value: Plan.yearly, description: Text("Two months free")),
                ])
            QeetrixRadioGroup(
                "Billing cycle", selection: $cycle,
                options: [QeetrixOption("Monthly", value: Plan.monthly), QeetrixOption("Yearly", value: Plan.yearly)],
                orientation: .horizontal)
            QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
        }
    }
}

/// PasswordInput.md, OTPInput.md, NumberField.md, FormActions.md and ErrorSummary.md.
private struct EntryExamples: View {
    enum Field: Hashable { case email, pan }

    @FocusState private var focus: Field?
    @State private var password = ""
    @State private var secret = ""
    @State private var code = ""
    @State private var recovery = ""
    @State private var seats: Int? = 5
    @State private var discount: Decimal? = nil
    @State private var amount: Decimal? = nil
    let isSubmitting = false

    var body: some View {
        VStack {
            QeetrixPasswordInput("Password", text: $password, isRequired: true)
                .submitLabel(.go)
                .onSubmit(signIn)
            QeetrixPasswordInput("Client secret", text: $secret, autoComplete: .off)
            QeetrixOTPInput("Verification code", code: $code, size: .lg) { completed in
                verify(completed)
            }
            QeetrixOTPInput("Recovery code", code: $recovery, length: 10, groups: [5, 5], validationType: .alphanumeric)
            QeetrixNumberField("Seats", value: $seats, in: 1...250)
            QeetrixNumberField(
                "Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1, endAdornment: Text("%"))
            QeetrixNumberField("Amount", value: $amount, startAdornment: Text("₹"), showsSteppers: false)
            QeetrixFormActions {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) { dismiss() }
                QeetrixButton("Create account", size: .lg, isLoading: isSubmitting) { submit() }
            }
            QeetrixErrorSummary(items: [
                .init(id: "email", message: "Enter a work email") { focus = .email },
                .init(id: "pan", message: "Enter the PAN as 10 characters") { focus = .pan },
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

@Suite("Form documentation examples")
struct FormDocumentationExamplesTests {
    @Test("Every form example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ChoiceExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: EntryExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SignUp().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
