import Qeetrix
import SwiftUI

struct SelectPage: View {
    @State private var country: String? = nil
    @State private var language = "en"

    private let countries: [QeetrixOption<String?>] = [
        QeetrixOption("India", value: "IN"),
        QeetrixOption("Germany", value: "DE"),
        QeetrixOption("United States", value: "US"),
        QeetrixOption("Antarctica", value: "AQ", description: Text("Not available"), isDisabled: true),
    ]

    var body: some View {
        ComponentPage(
            title: "Select",
            summary: "A choice from a list in the system menu, drawn as a Qeetrix field."
        ) {
            DemoSection("With a placeholder") {
                QeetrixSelect(
                    "Country", selection: $country, options: countries, placeholder: Text("Choose a country"),
                    message: country == nil ? .error("Choose a country.") : nil, isRequired: true)
                QeetrixText("Selected: \(country ?? "none")", variant: .muted)
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
            DemoSection("Disabled") {
                QeetrixSelect("Time zone", selection: .constant("IST"), options: [QeetrixOption("India Standard Time", value: "IST")])
                    .disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { SelectPage() }
}
