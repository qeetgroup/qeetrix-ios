import Qeetrix
import SwiftUI

struct PasswordInputPage: View {
    // Demonstration only: the page shows how many characters were typed, never the password.
    @State private var current = ""
    @State private var new = ""
    @State private var secret = "sk_test_51Hq"
    @State private var showsSecret = false

    var body: some View {
        ComponentPage(
            title: "Password input",
            summary: "Hidden by default, with a Show password toggle at the end and AutoFill. The app owns the value and its rules."
        ) {
            DemoSection("Sign in") {
                QeetrixPasswordInput("Password", text: $current, isRequired: true)
                QeetrixText("\(current.count) characters", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("password-length")
            }
            DemoSection("Create a password") {
                QeetrixPasswordInput(
                    "New password", text: $new, autoComplete: .newPassword,
                    description: Text("At least 12 characters."),
                    error: !new.isEmpty && new.count < 12 ? "Use at least 12 characters." : nil)
            }
            DemoSection("A secret, shown by the app") {
                QeetrixPasswordInput("API secret", text: $secret, autoComplete: .off, isVisible: $showsSecret)
                QeetrixText(showsSecret ? "Shown" : "Hidden", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("secret-visibility")
            }
            DemoSection("Disabled") {
                QeetrixPasswordInput("Managed password", text: .constant("")).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { PasswordInputPage() }
}
