#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Field snapshots")
    struct FieldSnapshotTests {
        @Test("Description, error replacing it, optional, disabled and a hidden label")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixField("Seats", description: Text("You can add more later.")) {
                        Color.clear.frame(height: 40).background(QeetrixColor.bgNeutralSubtle)
                    }
                    QeetrixField("Seats", description: Text("You can add more later."), error: "Choose between 1 and 250 seats") {
                        Color.clear.frame(height: 40).background(QeetrixColor.bgNeutralSubtle)
                    }
                    QeetrixField("Trade name", description: Text("As registered with GST."), isOptional: true) {
                        Color.clear.frame(height: 40).background(QeetrixColor.bgNeutralSubtle)
                    }
                    QeetrixField("Seats", description: Text("Your plan sets the seats.")) {
                        Color.clear.frame(height: 40).background(QeetrixColor.bgDisabled)
                    }
                    .disabled(true)
                    QeetrixField("Search", isLabelHidden: true) {
                        Color.clear.frame(height: 40).background(QeetrixColor.bgNeutralSubtle)
                    }
                }
            )
        }
    }
#endif
