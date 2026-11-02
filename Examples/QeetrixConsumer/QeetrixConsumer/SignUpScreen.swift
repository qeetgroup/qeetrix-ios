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
            VStack(alignment: .leading, spacing: QeetrixDensity.default.spaceFormGap) {
                QeetrixErrorSummary(
                    items: [Field.name, .email, .password, .country, .terms].compactMap { field in
                        errors[field].map { message in QeetrixErrorSummary.Item(id: "\(field)", message: message) { focus = field } }
                    })
                QeetrixTextField("Full name", text: $name, error: errors[.name], isRequired: true)
                    .focused($focus, equals: .name)
                QeetrixTextField(
                    "Work email", text: $email, prompt: Text(verbatim: "e.g. asha@acme.in"), error: errors[.email], isRequired: true
                )
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .focused($focus, equals: .email)
                QeetrixPasswordInput(
                    "Password", text: $password, autoComplete: .newPassword, description: Text("At least 12 characters."),
                    error: errors[.password], isRequired: true
                )
                .focused($focus, equals: .password)
                QeetrixSelect(
                    "Country", selection: $country, options: countries, placeholder: Text("Choose a country"),
                    error: errors[.country], isRequired: true)
                QeetrixCheckbox("I accept the terms", isOn: $acceptsTerms)
                QeetrixFormActions {
                    QeetrixButton("Create account", size: .lg) { submit() }
                }
            }
            .padding(QeetrixSpace.insetLg)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Sign up")
        .qeetrixToast($toast)
    }

    private func submit() {
        var found: [Field: String] = [:]
        if name.trimmingCharacters(in: .whitespaces).isEmpty { found[.name] = "Enter your name" }
        if !email.contains("@") { found[.email] = "Enter a work email, like asha@acme.in" }
        if password.count < 12 { found[.password] = "Use at least 12 characters" }
        if country == nil { found[.country] = "Choose a country" }
        if !acceptsTerms { found[.terms] = "Accept the terms to continue" }
        errors = found
        if found.isEmpty {
            toast = .success("Account created")
        }
    }
}
