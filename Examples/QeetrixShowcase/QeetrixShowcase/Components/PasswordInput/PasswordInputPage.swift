import Qeetrix
import SwiftUI

struct PasswordInputPage: View {
    // Demonstration only: the page shows how many characters were typed, never the password.
    @State private var current = ""
    @State private var new = ""

    var body: some View {
        ComponentPage(
            title: "Password input",
            summary: "Secure entry with a reveal toggle and Password AutoFill. The app owns the value and its rules."
        ) {
            DemoSection("Sign in") {
                QeetrixPasswordInput("Password", text: $current, purpose: .current, isRequired: true)
                QeetrixText("\(current.count) characters", variant: .muted)
                    .accessibilityIdentifier("password-length")
            }
            DemoSection("Create a password") {
                QeetrixPasswordInput(
                    "New password", text: $new, purpose: .new,
                    description: Text("At least 12 characters."),
                    message: !new.isEmpty && new.count < 12 ? .warning("Use at least 12 characters.") : nil)
            }
            DemoSection("Without a toggle, and disabled") {
                QeetrixPasswordInput("PIN", text: .constant(""), showsToggle: false)
                QeetrixPasswordInput("Managed password", text: .constant("")).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { PasswordInputPage() }
}
