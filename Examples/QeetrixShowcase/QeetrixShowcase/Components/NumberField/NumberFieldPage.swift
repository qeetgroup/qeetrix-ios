import Qeetrix
import SwiftUI

struct NumberFieldPage: View {
    @State private var seats: Int? = 5
    @State private var discount: Decimal? = 12.5
    @State private var adjustment: Decimal? = nil

    var body: some View {
        ComponentPage(
            title: "Number field",
            summary: "Locale-aware numbers with steppers. Typing keeps its in-between states; committing clamps and formats."
        ) {
            DemoSection("Whole numbers in a range") {
                QeetrixNumberField("Seats", value: $seats, in: 1...250, description: Text("Between 1 and 250."))
                QeetrixText("Seats: \(seats.map(String.init) ?? "empty")", variant: .muted)
                    .accessibilityIdentifier("seats-value")
            }
            DemoSection("Decimals") {
                QeetrixNumberField("Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1)
                QeetrixNumberField("Adjustment", value: $adjustment, prompt: Text("0"), isOptional: true)
                QeetrixText("Adjustment: \(adjustment.map { "\($0)" } ?? "empty")", variant: .muted)
                    .accessibilityIdentifier("adjustment-value")
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
