import Qeetrix
import SwiftUI

struct AvatarPage: View {
    var body: some View {
        ComponentPage(
            title: "Avatar",
            summary:
                "A person's photo or initials on a circle; an organisation, application or tenant on a square. VoiceOver reads the name."
        ) {
            DemoSection("Sizes") {
                HStack(spacing: QeetrixSpace.gapMd) {
                    ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                        QeetrixAvatar(name: "Asha Rao", size: size)
                    }
                }
            }
            DemoSection("People and organisations") {
                HStack(spacing: QeetrixSpace.gapMd) {
                    QeetrixAvatar(name: "Priya", size: .lg)
                    QeetrixAvatar(name: "Qeet Group", size: .lg, shape: .square)
                    QeetrixAvatar(name: "Kaveri Foods Private Limited", size: .lg, shape: .square)
                }
                QeetrixText("A company's legal form doesn't count: Kaveri Foods Private Limited is KF.", size: .sm, tone: .subtle)
            }
            DemoSection("Beside the name") {
                HStack(spacing: QeetrixSpace.gapSm) {
                    QeetrixAvatar(name: "Asha Rao", isDecorative: true)
                    QeetrixText("Asha Rao", weight: .medium)
                }
                QeetrixText("Decorative where the name is shown beside it, so VoiceOver reads it once.", size: .sm, tone: .subtle)
            }
        }
    }
}

#Preview {
    NavigationStack { AvatarPage() }
}
