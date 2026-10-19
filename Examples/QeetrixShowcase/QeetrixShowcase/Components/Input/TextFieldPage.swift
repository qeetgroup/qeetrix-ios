import Qeetrix
import SwiftUI

struct TextFieldPage: View {
    @State private var email = ""
    @State private var name = "Asha Rao"
    @State private var username = "asha"
    @State private var checked = false

    var body: some View {
        ComponentPage(
            title: "Text field",
            summary: "A labelled field with a description and an error, warning or success message."
        ) {
            DemoSection("Validation") {
                QeetrixTextField(
                    "Work email", text: $email,
                    prompt: Text("name@company.com"),
                    description: Text("We send sign-in links here."),
                    message: emailMessage,
                    isRequired: true
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                QeetrixButton("Check", variant: .outline, size: .sm) { checked = true }
            }
            DemoSection("Messages") {
                QeetrixTextField("Display name", text: $name, message: .warning("Your team sees this on every comment."))
                QeetrixTextField("Username", text: $username, message: QeetrixFieldMessage(.success, text: "Available."))
            }
            DemoSection("Read-only and disabled") {
                QeetrixTextField("Tenant ID", text: .constant("qeet-7f3a"), isReadOnly: true)
                QeetrixTextField("Organisation", text: .constant("Qeet Group")).disabled(true)
            }
        }
    }

    private var emailMessage: QeetrixFieldMessage? {
        guard checked else { return nil }
        return email.contains("@") && email.contains(".") ? .success("Looks good.") : .error("Enter a full email address.")
    }
}

#Preview {
    NavigationStack { TextFieldPage() }
}
