import Qeetrix
import SwiftUI

struct OTPInputPage: View {
    // Synthetic codes only: nothing here is sent, checked or stored.
    @State private var code = ""
    @State private var completions = 0
    @State private var backupCode = ""
    @State private var checked = false

    var body: some View {
        ComponentPage(
            title: "OTP input",
            summary: "One field box per character, spanning the column. AutoFill from Messages, paste and VoiceOver work on the whole code."
        ) {
            DemoSection("Verification code, sign-in size") {
                QeetrixOTPInput(
                    "Verification code", code: $code, groups: [3, 3], size: .lg,
                    description: Text("Sent to •••• 4821."),
                    error: checked && code.count < 6 ? "Enter all 6 digits." : nil
                ) { _ in
                    completions += 1
                }
                FlowLayout {
                    QeetrixButton("Check", variant: .ghost, size: .sm) { checked = true }
                    QeetrixButton("Clear", variant: .ghost, tone: .neutral, size: .sm) {
                        code = ""
                        checked = false
                    }
                }
                QeetrixText("\(code.count) of 6 entered, completed \(completions) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("otp-status")
            }
            DemoSection("A recovery code") {
                QeetrixOTPInput("Backup code", code: $backupCode, length: 8, groups: [4, 4], validationType: .alphanumeric)
            }
            DemoSection("Disabled") {
                QeetrixOTPInput(code: .constant("12"), length: 4).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { OTPInputPage() }
}
