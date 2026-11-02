#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Slider snapshots")
    struct SliderSnapshotTests {
        /// One value with its value shown, a range with its bounds in rupees, a percentage with an error
        /// and help, at the ends, and disabled.
        @Test("One value, a range with bounds, a percentage with help and an error, the ends, and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixSlider("Discount", value: .constant(20), in: 0...50, step: 5, showsValue: true)
                    QeetrixSlider(
                        "Budget", range: .constant(10_000...40_000), in: 0...100_000, step: 500,
                        format: .currency("INR", fractionDigits: 0...0),
                        showsValue: true, showsBounds: true
                    )
                    .environment(\.locale, Locale(identifier: "en_IN"))
                    QeetrixSlider(
                        "Alert threshold", value: .constant(0.4), in: 0...1, step: 0.05, format: .percent, showsValue: true,
                        description: Text("Alert when usage passes this share of the quota."))
                    QeetrixSlider(
                        "Alert threshold", value: .constant(0.05), in: 0...1, step: 0.05, format: .percent, error: "Set it above 10%")
                    QeetrixSlider("Volume", value: .constant(0), showsBounds: true)
                    QeetrixSlider("Volume", value: .constant(100))
                    QeetrixSlider("Discount", value: .constant(20), in: 0...50, showsValue: true).disabled(true)
                    QeetrixSlider("Budget", range: .constant(20...60)).disabled(true)
                }
            )
        }
    }
#endif
