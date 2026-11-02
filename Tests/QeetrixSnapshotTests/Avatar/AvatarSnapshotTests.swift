#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Avatar snapshots")
    struct AvatarSnapshotTests {
        @Test("Sizes and shapes, initials, a legal form and a photo")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixAvatarShape.allCases, id: \.self) { shape in
                        HStack(spacing: 8) {
                            ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                                QeetrixAvatar(name: "Priya Sharma", size: size, shape: shape)
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        QeetrixAvatar(name: "Kaveri Foods Private Limited", size: .lg, shape: .square)
                        QeetrixAvatar(name: "Acme Pvt Ltd", size: .lg, shape: .square)
                        QeetrixAvatar(name: "अनन्या राव", size: .lg)
                        QeetrixAvatar(name: "Ravi", image: Image(systemName: "person.crop.square.fill"), size: .lg)
                    }
                }
            )
        }
    }
#endif
