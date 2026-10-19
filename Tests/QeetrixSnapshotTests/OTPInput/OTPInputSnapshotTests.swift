#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    /// Synthetic codes only.
    @MainActor
    @Suite("OTP input snapshots")
    struct OTPInputSnapshotTests {
        @Test("Empty, part-filled, grouped and complete, error, letters and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixOTPInput("Verification code", code: .constant(""))
                    QeetrixOTPInput("Verification code", code: .constant("012"), description: Text("Sent to •••• 0000."))
                    QeetrixOTPInput("Verification code", code: .constant("123456"), groupSize: 3)
                    QeetrixOTPInput(
                        "Verification code", code: .constant("12"), message: QeetrixFieldMessage(.error, text: "Enter all 6 digits."))
                    QeetrixOTPInput("Backup code", code: .constant("AB12"), length: 8, characters: .alphanumeric, groupSize: 4)
                    QeetrixOTPInput(code: .constant("12"), length: 4).disabled(true)
                }
            )
        }
    }
#endif
