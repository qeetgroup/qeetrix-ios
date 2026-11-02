#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("OTP code snapshots")
    struct OTPCodeSnapshotTests {
        /// A fixed clock: the countdown stops there, so every run draws the same seconds. Codes are synthetic.
        static let start = Date(timeIntervalSinceReferenceDate: 800_000_010)

        static func code(
            _ code: String, size: QeetrixOTPCodeSize, secondsIn: TimeInterval, period: TimeInterval = 30, isHidden: Bool = false
        ) -> QeetrixOTPCode {
            QeetrixOTPCode(
                code: code, validity: start...start.addingTimeInterval(period), label: Text(verbatim: "Acme, priya@acme.in"), size: size,
                isHidden: isHidden, toast: nil, onCopied: nil, now: start.addingTimeInterval(secondsIn))
        }

        @Test("Six and eight digits at both sizes; the last 5 seconds in warning; a 60-second code; hidden; disabled")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 20) {
                    Self.code("482913", size: .lg, secondsIn: 12)
                    Self.code("48291375", size: .lg, secondsIn: 12)
                    Self.code("482913", size: .md, secondsIn: 12)
                    Self.code("48291375", size: .md, secondsIn: 12)
                    Self.code("482913", size: .lg, secondsIn: 27)
                    Self.code("482913", size: .md, secondsIn: 20, period: 60)
                    Self.code("482913", size: .lg, secondsIn: 12, isHidden: true)
                    Self.code("482913", size: .md, secondsIn: 12).disabled(true)
                }
            )
        }
    }
#endif
