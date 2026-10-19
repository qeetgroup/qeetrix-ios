#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Select snapshots")
    struct SelectSnapshotTests {
        private let countries: [QeetrixOption<String?>] = [QeetrixOption("India", value: "IN"), QeetrixOption("Germany", value: "DE")]

        @Test("Placeholder, selected, error and disabled")
        func states() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixSelect(
                        "Country", selection: .constant(nil), options: countries, placeholder: Text("Choose a country"), isRequired: true)
                    QeetrixSelect("Country", selection: .constant("DE"), options: countries, description: Text("Used for tax."))
                    QeetrixSelect(
                        "Country", selection: .constant(nil), options: countries, placeholder: Text("Choose a country"),
                        message: QeetrixFieldMessage(.error, text: "Choose a country."))
                    QeetrixSelect("Country", selection: .constant("IN"), options: countries).disabled(true)
                }
            )
        }
    }
#endif
