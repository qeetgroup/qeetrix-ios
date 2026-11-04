import Qeetrix
import SwiftUI

struct SelectPage: View {
    @State private var country: String? = nil
    @State private var language = "en"
    @State private var style = "Paragraph"

    private let countries: [QeetrixOption<String?>] = [
        QeetrixOption("India", value: "IN"),
        QeetrixOption("Germany", value: "DE"),
        QeetrixOption("United States", value: "US"),
        QeetrixOption("Antarctica", value: "AQ", description: Text("Not available"), isDisabled: true),
    ]

    var body: some View {
        ComponentPage(
            title: "Select",
            summary: "A choice from a short list, in the system menu, behind a trigger that looks like a field with a trailing chevron."
        ) {
            DemoSection("With a placeholder") {
                QeetrixSelect(
                    "Country", selection: $country, options: countries, placeholder: Text("Choose a country"),
                    error: country == nil ? "Choose a country." : nil, isRequired: true)
                QeetrixText("Selected: \(country ?? "none")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("country-selected")
            }
            DemoSection("With a default") {
                QeetrixSelect(
                    "Language", selection: $language,
                    options: [
                        QeetrixOption("English", value: "en"), QeetrixOption("हिन्दी", value: "hi"), QeetrixOption("Deutsch", value: "de"),
                    ],
                    description: Text("Used for emails."))
            }
            DemoSection("A toolbar's sizes, beside buttons") {
                HStack(spacing: QeetrixSpace.gapSm) {
                    QeetrixSelect(
                        "Text style", selection: $style,
                        options: ["Paragraph", "Heading", "Quote"].map { QeetrixOption($0, value: $0) }, size: .sm)
                    QeetrixButton("Apply", variant: .soft, size: .sm) {}
                }
            }
            DemoSection("Read-only and disabled") {
                QeetrixSelect(
                    "Currency", selection: .constant("INR"), options: [QeetrixOption("Indian rupee", value: "INR")], isReadOnly: true)
                QeetrixSelect("Time zone", selection: .constant("IST"), options: [QeetrixOption("India Standard Time", value: "IST")])
                    .disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { SelectPage() }
}
