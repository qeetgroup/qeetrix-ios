#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Avatar snapshots")
    struct AvatarSnapshotTests {
        @Test("Sizes, shapes, fallbacks and badges")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                            QeetrixAvatar(name: "Asha Rao", size: size)
                        }
                    }
                    HStack(spacing: 12) {
                        ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                            QeetrixAvatar(name: "Qeet Group", size: size, shape: .square)
                        }
                    }
                    HStack(spacing: 12) {
                        ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                            QeetrixAvatar(name: nil, size: size, badge: Text("Online"))
                        }
                    }
                    HStack(spacing: 12) {
                        QeetrixAvatar(name: "Priya", size: .lg, badge: Text("Online"))
                        QeetrixAvatar(name: "Workspace", size: .lg, shape: .square, badge: Text("Active"))
                        QeetrixAvatar(name: "Asha Rao", image: Image(systemName: "photo.fill"), size: .lg)
                    }
                }
            )
        }
    }
#endif
