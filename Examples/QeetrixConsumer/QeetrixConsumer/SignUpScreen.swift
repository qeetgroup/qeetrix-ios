import Qeetrix
import SwiftUI

/// A form as an app writes one: Qeetrix fields, the app's own validation and focus, an error summary, and a
/// toast for the outcome. The data is synthetic and goes nowhere.
struct SignUpScreen: View {
    enum Field: Hashable { case name, email, password, country, terms }

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var country: String?
    @State private var acceptsTerms = false
    @State private var errors: [Field: String] = [:]
    @State private var toast: QeetrixToast?
    @FocusState private var focus: Field?

    private let countries: [QeetrixOption<String?>] = [
        QeetrixOption("India", value: "IN"), QeetrixOption("Germany", value: "DE"), QeetrixOption("Saudi Arabia", value: "SA"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.l) {
                QeetrixFormErrorSummary(
                    errors: [Field.name, .email, .password, .country, .terms].compactMap { field in
                        errors[field].map { message in QeetrixFormErrorSummary.Item(id: "\(field)", message: "\(message)") { focus = field }
                        }
                    })
                QeetrixTextField("Full name", text: $name, message: errors[.name].map { .error("\($0)") }, isRequired: true)
                    .focused($focus, equals: .name)
                QeetrixTextField(
                    "Work email", text: $email, prompt: Text(verbatim: "name@company.com"), message: errors[.email].map { .error("\($0)") },
                    isRequired: true
                )
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .focused($focus, equals: .email)
                QeetrixPasswordInput(
                    "Password", text: $password, purpose: .new, description: Text("At least 12 characters."),
                    message: errors[.password].map { .error("\($0)") }, isRequired: true
                )
                .focused($focus, equals: .password)
                QeetrixSelect(
                    "Country", selection: $country, options: countries, placeholder: Text("Choose a country"),
                    message: errors[.country].map { .error("\($0)") }, isRequired: true)
                QeetrixCheckbox("I accept the terms", isOn: $acceptsTerms)
                QeetrixFormActions {
                    QeetrixButton("Create account") { submit() }
                }
            }
            .padding(QeetrixSpacing.l)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Sign up")
        .qeetrixToast($toast)
    }

    private func submit() {
        var found: [Field: String] = [:]
        if name.trimmingCharacters(in: .whitespaces).isEmpty { found[.name] = "Enter your name." }
        if !email.contains("@") { found[.email] = "Enter an email address with an @." }
        if password.count < 12 { found[.password] = "Use at least 12 characters." }
        if country == nil { found[.country] = "Choose a country." }
        if !acceptsTerms { found[.terms] = "Accept the terms to continue." }
        errors = found
        if found.isEmpty {
            toast = .success("Account created")
        }
    }
}
