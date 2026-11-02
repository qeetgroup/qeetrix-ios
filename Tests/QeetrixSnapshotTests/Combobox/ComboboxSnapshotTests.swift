#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Combobox snapshots")
    struct ComboboxSnapshotTests {
        static let countries = [
            QeetrixComboboxItem("India", value: "IN"),
            QeetrixComboboxItem("Germany", value: "DE", description: "Deutschland"),
            QeetrixComboboxItem("United Arab Emirates", value: "AE"),
            QeetrixComboboxItem("Antarctica", value: "AQ", description: "Not served yet", isDisabled: true),
        ]
        static let groups = [
            QeetrixComboboxSection(QeetrixComboboxGroup("Asia", items: [Self.countries[0], Self.countries[2]])),
            QeetrixComboboxSection(QeetrixComboboxGroup("Europe", items: [Self.countries[1]])),
            QeetrixComboboxSection(QeetrixComboboxGroup("Elsewhere", items: [Self.countries[3]])),
        ]

        @Test("The trigger: placeholder, chosen, several, open, error, read-only and disabled")
        func triggers() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixCombobox("Country", selection: .constant("none"), items: Self.countries, placeholder: Text("e.g. India"))
                    QeetrixCombobox(
                        "Country", selection: .constant("AE"), items: Self.countries, description: Text("Where you're registered."))
                    QeetrixCombobox("Countries served", selection: .constant(Set(["IN", "DE", "AE"])), items: Self.countries)
                    QeetrixComboboxTrigger(
                        value: Text("India"), placeholder: nil, accessibilityValue: Text("India"), isOpen: true, isReadOnly: false,
                        action: {})
                    QeetrixCombobox(
                        "Country", selection: .constant("none"), items: Self.countries, error: "Choose the country you're registered in")
                    QeetrixCombobox("Country", selection: .constant("IN"), items: Self.countries, isReadOnly: true)
                    QeetrixCombobox("Country", selection: .constant("IN"), items: Self.countries).disabled(true)
                }
            )
        }

        @Test("The sheet for one choice: groups, the chosen option's check, a disabled option")
        func sheet() {
            assertSpecimen(
                QeetrixComboboxSheet(
                    title: Text("Country"), sections: Self.groups, selection: .single(.constant("AE")),
                    searchPrompt: Text("e.g. Germany"), isLoading: false, messages: QeetrixComboboxMessages(),
                    searchDelay: .milliseconds(300), onSearch: nil
                )
                .frame(height: 520)
                .background(QeetrixColor.surfaceOverlay)
            )
        }

        @Test("The sheet for several choices, searched: Done, and the matches with their checks")
        func severalSearched() {
            assertSpecimen(
                QeetrixComboboxSheet(
                    title: Text("Countries served"), sections: [QeetrixComboboxSection(Self.countries)],
                    selection: .multiple(.constant(["IN", "AE"])), searchPrompt: nil, isLoading: false,
                    messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil, query: "in"
                )
                .frame(height: 360)
                .background(QeetrixColor.surfaceOverlay)
            )
        }

        @Test("No matches, and a server search on its way")
        func emptyAndLoading() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixComboboxSheet(
                        title: Text("Country"), sections: Self.groups, selection: .single(.constant("IN")), searchPrompt: nil,
                        isLoading: false, messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil,
                        query: "Atlantis"
                    )
                    .frame(height: 300)
                    QeetrixComboboxSheet(
                        title: Text("Owner"), sections: [QeetrixComboboxSection(Array(Self.countries.prefix(2)))],
                        selection: .single(.constant("IN")), searchPrompt: nil, isLoading: true, messages: QeetrixComboboxMessages(),
                        searchDelay: .milliseconds(300), onSearch: { _ in }, query: "Ind"
                    )
                    .frame(height: 300)
                }
                .background(QeetrixColor.surfaceOverlay)
            )
        }
    }
#endif
