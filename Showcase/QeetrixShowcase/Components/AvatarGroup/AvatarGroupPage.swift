import Qeetrix
import SwiftUI

struct AvatarGroupPage: View {
    private let people = ["Priya Sharma", "Rahul Verma", "Ananya Iyer", "Kabir Rao", "Meera Nair"].map {
        QeetrixAvatarGroupPerson(name: $0)
    }

    var body: some View {
        ComponentPage(
            title: "Avatar group",
            summary: "A few people at a glance: avatars side by side, 2 pt apart, then +N. VoiceOver reads the whole group as one image."
        ) {
            DemoSection("Sizes") {
                ForEach(QeetrixAvatarSize.allCases, id: \.self) { size in
                    QeetrixAvatarGroup(people: people, size: size)
                }
            }
            DemoSection("A large group") {
                QeetrixAvatarGroup(people: Array(people.prefix(3)), total: 412, size: .md)
                QeetrixText("412 members: the first three are shown, then +409.", size: .sm, tone: .subtle)
            }
            DemoSection("One left over shows as a face") {
                QeetrixAvatarGroup(people: Array(people.prefix(4)), size: .md)
            }
            DemoSection("Organisations and applications") {
                QeetrixAvatarGroup(
                    people: ["Qeet Pay", "Qeet People", "Qeet Logs", "Qeet Notify", "Qeet ID"].map { QeetrixAvatarGroupPerson(name: $0) },
                    size: .lg, shape: .square,
                    label: Text("5 applications: Qeet Pay, Qeet People, Qeet Logs and 2 more"))
            }
        }
    }
}

#Preview {
    NavigationStack { AvatarGroupPage() }
}
