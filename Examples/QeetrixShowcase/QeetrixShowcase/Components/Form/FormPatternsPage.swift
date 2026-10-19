import Qeetrix
import SwiftUI

/// Generic form layouts built from Qeetrix fields and native SwiftUI: no network, no accounts, dummy data
/// only. The page owns state, focus and validation; Qeetrix only presents them.
struct FormPatternsPage: View {
    enum Field: Hashable {
        case name, email, password, code
    }

    @FocusState private var focus: Field?
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role: String? = nil
    @State private var accepted = false
    @State private var errors: [Field: String] = [:]
    @State private var isSubmitting = false
    @State private var submissions = 0
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        ComponentPage(
            title: "Form patterns",
            summary: "A registration-style and a settings-style layout. The app validates; the fields present."
        ) {
            DemoSection("Registration") {
                VStack(alignment: .leading, spacing: density.fieldGap * 1.5) {  // Form: sections 1.5 field gaps apart
                    QeetrixFormErrorSummary(errors: summaryItems)
                    QeetrixFieldSet("Your details") {
                        QeetrixTextField("Full name", text: $name, message: message(.name), isRequired: true)
                            .focused($focus, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focus = .email }
                        QeetrixTextField(
                            "Work email", text: $email, prompt: Text("name@company.com"), message: message(.email), isRequired: true
                        )
                        .focused($focus, equals: .email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }
                        QeetrixPasswordInput("Password", text: $password, purpose: .new, message: message(.password), isRequired: true)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .onSubmit(submit)
                        QeetrixSelect(
                            "Role", selection: $role,
                            options: [
                                QeetrixOption("Engineering", value: "eng"), QeetrixOption("Design", value: "design"),
                                QeetrixOption("Other", value: "other"),
                            ],
                            placeholder: Text("Choose a role"), isOptional: true)
                    }
                    QeetrixCheckbox("I agree to the terms", isOn: $accepted)
                    QeetrixFormActions {
                        QeetrixButton("Reset", variant: .outline) { reset() }
                        QeetrixButton("Create account", isLoading: isSubmitting, loadingLabel: "Creating account") { submit() }
                    }
                    QeetrixText("Submitted \(submissions) times", variant: .muted)
                        .accessibilityIdentifier("form-submissions")
                }
            }
            DemoSection("Settings") {
                SettingsForm()
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var summaryItems: [QeetrixFormErrorSummary.Item] {
        [Field.name, .email, .password].compactMap { field in
            errors[field].map { message in QeetrixFormErrorSummary.Item(id: "\(field)", message: message) { focus = field } }
        }
    }

    private func message(_ field: Field) -> QeetrixFieldMessage? {
        errors[field].map { QeetrixFieldMessage(.error, text: $0) }
    }

    /// Dummy validation, standing in for the app's own rules.
    private func submit() {
        var found: [Field: String] = [:]
        if name.trimmingCharacters(in: .whitespaces).isEmpty { found[.name] = "Enter your name." }
        if !email.contains("@") { found[.email] = "Enter an email address with an @." }
        if password.count < 12 { found[.password] = "Use at least 12 characters." }
        errors = found
        guard found.isEmpty else {
            focus = [Field.name, .email, .password].first { found[$0] != nil }
            return
        }
        isSubmitting = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            isSubmitting = false
            submissions += 1
        }
    }

    private func reset() {
        name = ""
        email = ""
        password = ""
        role = nil
        accepted = false
        errors = [:]
        focus = nil
    }
}

/// A settings-style layout: grouped switches, a select, a number field and a note, saved as one.
private struct SettingsForm: View {
    @State private var digest = true
    @State private var mentions = true
    @State private var frequency = "daily"
    @State private var retention: Int? = 30
    @State private var note = ""
    @State private var saved = false
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        VStack(alignment: .leading, spacing: density.fieldGap * 1.5) {
            QeetrixFieldSet("Email", description: Text("What we send you.")) {
                QeetrixSwitch("Weekly digest", isOn: $digest)
                QeetrixSwitch("Mentions", isOn: $mentions)
                QeetrixSelect(
                    "Frequency", selection: $frequency,
                    options: [QeetrixOption("Daily", value: "daily"), QeetrixOption("Weekly", value: "weekly")]
                )
                .disabled(!digest)
            }
            QeetrixFieldSet("Data") {
                QeetrixNumberField("Keep logs for (days)", value: $retention, in: 7...365)
                QeetrixTextarea("Note for administrators", text: $note, isOptional: true)
            }
            QeetrixFormActions {
                QeetrixButton("Save settings") { saved = true }
            }
            if saved {
                QeetrixBadge("Saved", variant: .success, icon: .circleCheck)
            }
        }
    }
}

#Preview {
    NavigationStack { FormPatternsPage() }
}
