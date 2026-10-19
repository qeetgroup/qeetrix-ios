#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Number field snapshots")
    struct NumberFieldSnapshotTests {
        @Test("A value, a decimal, empty with a prompt, at its bound, error and disabled")
        func states() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixNumberField("Seats", value: .constant(1250), description: Text("Grouped for the locale."))
                    QeetrixNumberField("Discount", value: .constant(Decimal(string: "12.5")), fractionDigits: 1)
                    QeetrixNumberField("Adjustment", value: .constant(Decimal?.none), prompt: Text("0"), isOptional: true)
                    QeetrixNumberField("Seats", value: .constant(250), in: 1...250)
                    QeetrixNumberField("Seats", value: .constant(0), message: QeetrixFieldMessage(.error, text: "At least 1."))
                    QeetrixNumberField("Quota", value: .constant(10)).disabled(true)
                }
            )
        }
    }
#endif
