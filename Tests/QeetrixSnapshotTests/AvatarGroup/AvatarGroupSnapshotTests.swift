#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Avatar group snapshots")
    struct AvatarGroupSnapshotTests {
        static let people = ["Priya Sharma", "Rahul Verma", "Ananya Iyer", "Kabir Rao"].map { QeetrixAvatarGroupPerson(name: $0) }

        @Test("Every size, +N, one left over as a face, a large total, squares, and a photo")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                        QeetrixAvatarGroup(people: Self.people + Self.people, size: size)
                    }
                    QeetrixAvatarGroup(people: Self.people, size: .md)
                    QeetrixAvatarGroup(people: Array(Self.people.prefix(3)), total: 1_412, size: .md)
                    QeetrixAvatarGroup(
                        people: ["Qeet Pay", "Qeet People", "Qeet Logs", "Qeet Notify", "Qeet ID"].map {
                            QeetrixAvatarGroupPerson(name: $0)
                        },
                        size: .lg, shape: .square)
                    QeetrixAvatarGroup(
                        people: [
                            QeetrixAvatarGroupPerson(name: "Ravi", image: Image(systemName: "person.crop.square.fill")),
                            QeetrixAvatarGroupPerson(name: "अनन्या राव"),
                        ], size: .lg)
                }
            )
        }
    }
#endif
