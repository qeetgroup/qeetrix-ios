#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Number field snapshots")
    struct NumberFieldSnapshotTests {
        @Test("A value, a decimal with a unit, an amount without steppers, at its bound, an error and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixNumberField("Seats", value: .constant(12), in: 1...250)
                    QeetrixNumberField(
                        "Discount", value: .constant(Decimal(string: "12.5")), in: 0...100, step: Decimal(string: "0.5")!,
                        fractionDigits: 1,
                        endAdornment: Text("%"))
                    QeetrixNumberField("Amount", value: .constant(Decimal(120000)), startAdornment: Text("₹"), showsSteppers: false)
                    QeetrixNumberField("Seats", value: .constant(250), in: 1...250, prompt: Text("e.g. 10"))
                    QeetrixNumberField("Seats", value: .constant(0), in: 0...250, error: "Choose at least 1 seat")
                    QeetrixNumberField("Seats", value: .constant(5), in: 1...250).disabled(true)
                }
            )
        }
    }
#endif
