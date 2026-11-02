import Qeetrix
import SwiftUI

struct SliderPage: View {
    @State private var discount = 20.0
    @State private var budget = 10_000.0...40_000.0
    @State private var threshold = 0.4
    @State private var volume = 60.0

    var body: some View {
        ComponentPage(
            title: "Slider",
            summary: "A value or a range on a scale: a 4 pt track, square Ember thumbs, each a 44 pt target and adjustable for VoiceOver."
        ) {
            DemoSection("One value") {
                QeetrixSlider("Discount", value: $discount, in: 0...50, step: 5, showsValue: true)
                QeetrixSlider("Volume", value: $volume, showsBounds: true) { isEditing in
                    if !isEditing { print("Volume set to \(Int(volume))") }
                }
            }
            DemoSection("A range") {
                QeetrixSlider(
                    "Budget", range: $budget, in: 0...100_000, step: 500, format: .currency("INR", fractionDigits: 0...0), showsValue: true,
                    showsBounds: true
                )
                .environment(\.locale, Locale(identifier: "en_IN"))
            }
            DemoSection("A percentage, with help and an error") {
                QeetrixSlider(
                    "Alert threshold", value: $threshold, in: 0...1, step: 0.05, format: .percent, showsValue: true,
                    description: Text("Alert when usage passes this share of the quota."),
                    error: threshold < 0.1 ? "Set it above 10%" : nil)
            }
            DemoSection("Disabled") {
                QeetrixSlider("Discount", value: .constant(20), in: 0...50, showsValue: true).disabled(true)
                QeetrixSlider("Budget", range: .constant(20...60)).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { SliderPage() }
}
