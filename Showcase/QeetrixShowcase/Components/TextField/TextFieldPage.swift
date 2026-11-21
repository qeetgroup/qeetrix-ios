import Qeetrix
import SwiftUI

struct TextFieldPage: View {
    @State private var email = ""
    @State private var amount = ""
    @State private var subdomain = "acme"
    @State private var checked = false
    @State private var phone = ""
    @State private var name = "Meera"

    var body: some View {
        ComponentPage(
            title: "Text field",
            summary: "A filled field with a strong bottom line: the label above, help text or an error below."
        ) {
            DemoSection("Validation") {
                QeetrixTextField(
                    "Work email", text: $email,
                    prompt: Text("e.g. asha@acme.in"),
                    description: Text("We send sign-in links here."),
                    error: emailError,
                    isRequired: true
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                HStack(spacing: QeetrixSpace.gapMd) {
                    QeetrixButton("Check", size: .lg) { checked = true }
                    QeetrixText(checked && emailError == nil ? "Looks good." : "", size: .sm, tone: .success)
                        .accessibilityIdentifier("email-status")
                }
            }
            DemoSection("Large, for the one value a step asks for") {
                QeetrixTextField(
                    "Phone number", text: $phone, prompt: Text("10-digit mobile number"), startAdornment: Text("+91"), size: .lg
                )
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                QeetrixTextField("Your name", text: $name, description: Text("Your contacts see it."), size: .lg)
                    .textContentType(.name)
            }
            DemoSection("An icon and affixes") {
                QeetrixTextField("Search", text: .constant(""), prompt: Text("e.g. INV-0042"), icon: .search)
                QeetrixTextField("Amount", text: $amount, prompt: Text("0.00"), startAdornment: Text("₹"))
                    .keyboardType(.decimalPad)
                QeetrixTextField("Workspace address", text: $subdomain, endAdornment: Text(".qeet.in"))
                    .textInputAutocapitalization(.never)
            }
            DemoSection("Read-only and disabled") {
                QeetrixTextField("Tenant ID", text: .constant("qeet-7f3a"), isReadOnly: true)
                QeetrixTextField("Organisation", text: .constant("Qeet Group")).disabled(true)
            }
        }
    }

    private var emailError: String? {
        guard checked else { return nil }
        return email.contains("@") && email.contains(".") ? nil : "Enter a full email address."
    }
}

#Preview {
    NavigationStack { TextFieldPage() }
}
