#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Radio group snapshots")
    struct RadioGroupSnapshotTests {
        static let options = [
            QeetrixOption("Monthly", value: 1),
            QeetrixOption("Yearly", value: 2, description: Text("Two months free")),
            QeetrixOption("Lifetime", value: 3, isDisabled: true),
        ]

        @Test("Nothing selected, selected, a disabled option, horizontal, an error and a disabled group")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixRadioGroup("Billing cycle", selection: .constant(0), options: Self.options)
                    QeetrixRadioGroup(
                        "Billing cycle", selection: .constant(2), options: Self.options, description: Text("Change it any time."))
                    QeetrixRadioGroup(
                        "Plan", selection: .constant(1), options: [QeetrixOption("Starter", value: 1), QeetrixOption("Team", value: 2)],
                        orientation: .horizontal)
                    QeetrixRadioGroup(
                        "Billing cycle", selection: .constant(0), options: Self.options, error: "Choose how often you're billed")
                    QeetrixRadioGroup("Billing cycle", selection: .constant(3), options: Self.options).disabled(true)
                }
            )
        }

        @Test("Tiles: icons and lines, chosen, a disabled option, two columns, an error, and icons in rows")
        func tiles() {
            let photo = [
                QeetrixOption("Everyone", value: 1, description: Text("Anyone with your number"), icon: .users),
                QeetrixOption("My contacts", value: 2, description: Text("People in your phone's contacts"), icon: .contactRound),
                QeetrixOption("Nobody", value: 3, description: Text("Only you see it"), icon: .eyeOff, isDisabled: true),
            ]
            let languages = ["English", "हिन्दी", "বাংলা", "తెలుగు"].enumerated().map { QeetrixOption($0.element, value: $0.offset) }
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixRadioGroup("Who can see your photo", selection: .constant(2), options: photo, variant: .tile)
                    QeetrixRadioGroup("Language", selection: .constant(1), options: languages, variant: .tile, columns: 2)
                    QeetrixRadioGroup(
                        "Language", selection: .constant(9), options: languages, error: "Choose a language", variant: .tile, columns: 2)
                    QeetrixRadioGroup("Who can see your photo", selection: .constant(1), options: photo)
                }
            )
        }
    }
#endif
