#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("List item snapshots")
    struct ListItemSnapshotTests {
        @Test("Content, value, icon tile, avatar, chevron, switch on and off, destructive, selected and disabled rows")
        func variants() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixListItem("Storage", description: Text("Used this month"), metadata: Text("2.4 GB")) {
                        QeetrixListItemIcon(.database)
                    } trailing: {
                        QeetrixBadge("Pro", tone: .brand)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), accessory: .chevron) {
                        QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Face ID", description: Text("Unlock Qeet Auth with your face"), isOn: .constant(true)) {
                        QeetrixListItemIcon(.scanLine)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Notifications", isOn: .constant(false)) { QeetrixListItemIcon(.bell) }
                    QeetrixSeparator()
                    QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron, action: {})
                    QeetrixSeparator()
                    QeetrixListItem("Ada Lovelace", description: Text("Selected"), isSelected: true, action: {}) {
                        QeetrixAvatar(name: "Ada Lovelace", isDecorative: true)
                    } trailing: {
                        QeetrixIcon(.check, size: .sm, shape: .sharp).foregroundStyle(QeetrixColor.iconBrand)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Sign out", role: .destructive, action: {}) { QeetrixListItemIcon(.x) }
                    QeetrixSeparator()
                    QeetrixListItem("Managed by Acme", description: Text("Your organisation sets this"), isOn: .constant(true)) {
                        QeetrixListItemIcon(.lock)
                    }
                    .disabled(true)
                }
            )
        }

        @Test("Rows in each density: 44, 44 and 48 pt")
        func densities() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixListItem("Compact", metadata: Text("44 pt")).qeetrixDensity(.compact)
                    QeetrixSeparator()
                    QeetrixListItem("Default", metadata: Text("44 pt"))
                    QeetrixSeparator()
                    QeetrixListItem("Comfortable", metadata: Text("48 pt")).qeetrixDensity(.comfortable)
                }
            )
        }

        @Test("In a plain List: the row's insets, raised surface and border.subtle separators, edge to edge")
        func inList() {
            assertSpecimen(
                List {
                    Section {
                        QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), accessory: .chevron) {
                            QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                        }
                        QeetrixListItem("Kaveri Foods", description: Text(verbatim: "admin@kaveri.in"), accessory: .chevron) {
                            QeetrixAvatar(name: "Kaveri Foods", shape: .square, isDecorative: true)
                        }
                    } header: {
                        QeetrixSectionHeader("Accounts", isRuled: false)
                    }
                    .listSectionSeparator(.hidden)
                    Section {
                        QeetrixListItem("Face ID", isOn: .constant(true)) { QeetrixListItemIcon(.scanLine) }
                        QeetrixListItem("Sign out", role: .destructive, action: {})
                    } header: {
                        QeetrixSectionHeader("Security")
                    }
                    .listSectionSeparator(.hidden)
                }
                .qeetrixListStyle()
                .frame(height: 420)
            )
        }
    }
#endif
