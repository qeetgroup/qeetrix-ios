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
            summary: "One native field drawn as cells: AutoFill from Messages, paste and VoiceOver work on the whole code."
        ) {
            DemoSection("Verification code") {
                QeetrixOTPInput(
                    "Verification code", code: $code, groupSize: 3,
                    description: Text("Sent to •••• 4821."),
                    message: checked && code.count < 6 ? .error("Enter all 6 digits.") : nil
                ) { _ in
                    completions += 1
                }
                FlowLayout {
                    QeetrixButton("Check", variant: .outline, size: .sm) { checked = true }
                    QeetrixButton("Clear", variant: .ghost, size: .sm) {
                        code = ""
                        checked = false
                    }
                }
                QeetrixText("\(code.count) of 6 entered, completed \(completions) times", variant: .muted)
                    .accessibilityIdentifier("otp-status")
            }
            DemoSection("Letters and digits") {
                QeetrixOTPInput("Backup code", code: $backupCode, length: 8, characters: .alphanumeric, groupSize: 4)
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
