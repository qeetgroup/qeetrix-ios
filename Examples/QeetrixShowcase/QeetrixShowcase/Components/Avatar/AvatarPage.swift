import Qeetrix
import SwiftUI

struct AvatarPage: View {
    var body: some View {
        ComponentPage(
            title: "Avatar",
            summary: "A person's picture, initials or a neutral icon. VoiceOver reads the name, then the badge."
        ) {
            DemoSection("Sizes") {
                HStack(spacing: QeetrixSpacing.m) {
                    ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                        QeetrixAvatar(name: "Asha Rao", size: size)
                    }
                }
            }
            DemoSection("Shapes and fallbacks") {
                HStack(spacing: QeetrixSpacing.m) {
                    QeetrixAvatar(name: "Priya", size: .lg)
                    QeetrixAvatar(name: "Qeet Group", size: .lg, shape: .square)
                    QeetrixAvatar(name: nil, size: .lg)
                }
            }
            DemoSection("With a status badge") {
                HStack(spacing: QeetrixSpacing.m) {
                    QeetrixAvatar(name: "Asha Rao", size: .lg, badge: Text("Online"))
                    QeetrixAvatar(name: "Workspace", size: .lg, shape: .square, badge: Text("Active"))
                }
            }
        }
    }
}

#Preview {
    NavigationStack { AvatarPage() }
}
