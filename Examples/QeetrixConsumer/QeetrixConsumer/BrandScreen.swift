import Qeetrix
import SwiftUI

/// Foundations as an app uses them: semantic colours, the type roles, icons, space, radii and badges —
/// every value from Qeetrix, none typed in.
struct BrandScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.layoutSm) {
                QeetrixCard(title: Text("Your account"), description: Text("Security")) {
                    HStack(spacing: QeetrixSpace.gapXs) {
                        QeetrixIcon(.lock, size: .sm, shape: .sharp, variant: .filled)
                            .foregroundStyle(QeetrixColor.iconSuccess)
                        QeetrixText("Two-step verification is on", tone: .subtle)
                    }
                }

                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    ForEach(QeetrixTextRole.allCases, id: \.self) { role in
                        Text(role.rawValue)
                            .qeetrixTextStyle(role)
                            .foregroundStyle(QeetrixColor.textDefault)
                            .accessibilityLabel(Self.spokenName(role))
                    }
                }

                HStack(spacing: QeetrixSpace.gapMd) {
                    ForEach([QeetrixIconName.bell, .inbox, .settings, .search, .send], id: \.self) { name in
                        QeetrixIcon(name, shape: .sharp, label: Text(name.rawValue))
                            .foregroundStyle(QeetrixColor.iconDefault)
                    }
                }

                HStack(spacing: QeetrixSpace.gapSm) {
                    QeetrixBadge("Active", tone: .success)
                    QeetrixBadge("Draft")
                    QeetrixBadge("Blocked", tone: .danger)
                }
            }
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Brand")
    }

    /// A role's token name read as words, "display.lg" as "display large": VoiceOver would spell out the
    /// abbreviation.
    static func spokenName(_ role: QeetrixTextRole) -> String {
        let sizes = ["lg": "large", "md": "medium", "sm": "small", "caps": "capitals"]
        return role.rawValue.split(separator: ".").map { sizes[String($0)] ?? String($0) }.joined(separator: " ")
    }
}
