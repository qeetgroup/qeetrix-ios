import Qeetrix
import SwiftUI

struct NumberFieldPage: View {
    @State private var seats: Int? = 5
    @State private var discount: Decimal? = 12.5
    @State private var adjustment: Decimal? = nil
    @State private var amount: Decimal? = 125_000

    var body: some View {
        ComponentPage(
            title: "Number field",
            summary: "A number in the field box, in tabular figures, with − and + steppers at its end. Committing clamps and formats."
        ) {
            DemoSection("Whole numbers in a range") {
                QeetrixNumberField("Seats", value: $seats, in: 1...250, description: Text("Between 1 and 250."))
                QeetrixText("Seats: \(seats.map(String.init) ?? "empty")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("seats-value")
            }
            DemoSection("Decimals and units") {
                QeetrixNumberField(
                    "Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1, endAdornment: Text("%"))
                QeetrixNumberField("Adjustment", value: $adjustment, prompt: Text("0"), isOptional: true)
                QeetrixText("Adjustment: \(adjustment.map { "\($0)" } ?? "empty")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("adjustment-value")
            }
            DemoSection("An amount nobody steps through") {
                QeetrixNumberField("Invoice amount", value: $amount, startAdornment: Text("₹"), showsSteppers: false)
                    .environment(\.locale, Locale(identifier: "en_IN"))
            }
            DemoSection("In another locale") {
                QeetrixNumberField("Betrag", value: $adjustment)
                    .environment(\.locale, Locale(identifier: "de_DE"))
            }
            DemoSection("Disabled") {
                QeetrixNumberField("Quota", value: .constant(10)).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { NumberFieldPage() }
}
