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
            _ code: String, size: QeetrixOTPCodeSize, secondsIn: TimeInterval, period: TimeInterval = 30, isHidden: Bool = false,
            action: QeetrixOTPCodeAction? = nil
        ) -> QeetrixOTPCode {
            QeetrixOTPCode(
                code: code, validity: start...start.addingTimeInterval(period), label: Text(verbatim: "Acme, priya@acme.in"), size: size,
                isHidden: isHidden, toast: nil, onCopied: nil, action: action, now: start.addingTimeInterval(secondsIn))
        }

        static func variants(action: QeetrixOTPCodeAction?) -> some View {
            VStack(alignment: .leading, spacing: 20) {
                code("482913", size: .lg, secondsIn: 12, action: action)
                code("48291375", size: .lg, secondsIn: 12, action: action)
                code("482913", size: .md, secondsIn: 12, action: action)
                code("48291375", size: .md, secondsIn: 12, action: action)
                code("482913", size: .lg, secondsIn: 27, action: action)
                code("482913", size: .md, secondsIn: 20, period: 60, action: action)
                code("482913", size: .lg, secondsIn: 12, isHidden: true, action: action)
                code("482913", size: .md, secondsIn: 12, action: action).disabled(true)
            }
        }

        @Test("Six and eight digits at both sizes; the last 5 seconds in warning; a 60-second code; hidden; disabled")
        func variants() {
            assertSpecimen(Self.variants(action: nil))
        }

        /// A code that runs the app's action draws as one that copies. Its baselines are the same
        /// images as `variants()`'s; OTPCodeTests compares the two renders pixel by pixel.
        @Test("With the app's action, every variant draws as the copying code does")
        func variantsWithAnAction() {
            assertSpecimen(Self.variants(action: QeetrixOTPCodeAction(hint: Text(verbatim: "Fills the code")) { _ in }))
        }
    }
#endif
