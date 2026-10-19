#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Button snapshots")
    struct ButtonSnapshotTests {
        @Test("Variants, sizes, icons, disabled and loading")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    FlowLayout {
                        ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                            QeetrixButton(variant.rawValue, variant: variant) {}
                        }
                    }
                    FlowLayout {
                        ForEach(QeetrixButtonSize.allCases, id: \.self) { size in
                            QeetrixButton("Size \(size.rawValue)", leadingIcon: .check, size: size) {}
                        }
                    }
                    FlowLayout {
                        QeetrixButton("Send", trailingIcon: .send, variant: .outline) {}
                        QeetrixButton("Search", leadingIcon: .search, variant: .secondary) {}
                    }
                    FlowLayout {
                        ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                            QeetrixButton(variant.rawValue, variant: variant) {}.disabled(true)
                        }
                    }
                    FlowLayout {
                        QeetrixButton("Save", isLoading: true) {}
                        QeetrixButton("Save", leadingIcon: .check, variant: .outline, isLoading: true) {}
                        QeetrixButton("Save changes", variant: .secondary, isLoading: true, loadingLabel: "Saving") {}
                    }
                }
            )
        }

        @Test("Icon buttons: variants, sizes, disabled and loading")
        func iconButtons() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    FlowLayout {
                        ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                            QeetrixIconButton(.bell, label: "Notifications", variant: variant) {}
                        }
                    }
                    FlowLayout {
                        ForEach(QeetrixButtonSize.allCases, id: \.self) { size in
                            QeetrixIconButton(.x, label: "Close", variant: .outline, size: size) {}
                        }
                        QeetrixIconButton(.x, label: "Close", variant: .outline) {}.disabled(true)
                        QeetrixIconButton(.send, label: "Send", variant: .default, isLoading: true) {}
                    }
                }
            )
        }
    }
#endif
