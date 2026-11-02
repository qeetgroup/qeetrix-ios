#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("One-time code snapshots")
    struct OTPInputSnapshotTests {
        @Test("Empty, partly filled, grouped at lg, a recovery code, an error and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixOTPInput("Verification code", code: .constant(""))
                    QeetrixOTPInput("Verification code", code: .constant("482"), description: Text("Sent to •••• 3412."))
                    QeetrixOTPInput("Verification code", code: .constant("482913"), groups: [3, 3], size: .lg)
                    QeetrixOTPInput("Recovery code", code: .constant("AB12C"), length: 10, groups: [5, 5], validationType: .alphanumeric)
                    QeetrixOTPInput("Verification code", code: .constant("000000"), error: "That code didn't work. Request a new one")
                    QeetrixOTPInput("Verification code", code: .constant("12")).disabled(true)
                }
            )
        }
    }
#endif
