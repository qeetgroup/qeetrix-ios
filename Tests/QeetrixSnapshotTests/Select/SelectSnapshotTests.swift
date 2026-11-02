#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Select snapshots")
    struct SelectSnapshotTests {
        static let options = [QeetrixOption("India", value: "IN"), QeetrixOption("Singapore", value: "SG")]

        @Test("Placeholder, selected, toolbar sizes, error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixSelect("Country", selection: .constant(""), options: Self.options, placeholder: Text("Choose a country"))
                    QeetrixSelect(
                        "Country", selection: .constant("IN"), options: Self.options, description: Text("Where you're registered."))
                    HStack(spacing: 8) {
                        QeetrixSelect("Sort", selection: .constant("IN"), options: Self.options, size: .md)
                        QeetrixSelect("Sort", selection: .constant("SG"), options: Self.options, size: .sm)
                    }
                    QeetrixSelect(
                        "Country", selection: .constant(""), options: Self.options, error: "Choose the country you're registered in")
                    QeetrixSelect("Country", selection: .constant("IN"), options: Self.options, isReadOnly: true)
                    QeetrixSelect("Country", selection: .constant("IN"), options: Self.options).disabled(true)
                }
            )
        }
    }
#endif
