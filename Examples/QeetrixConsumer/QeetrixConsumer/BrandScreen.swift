import Qeetrix
import SwiftUI

/// Foundations as an app uses them: semantic colours, the typography roles, icons, spacing, corners and
/// elevation — every value from Qeetrix, none typed in.
struct BrandScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.l) {
                QeetrixCard {
                    VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
                        Text("Your account")
                            .qeetrixTextStyle(.heading)
                            .foregroundStyle(QeetrixColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        HStack(spacing: QeetrixSpacing.xs) {
                            QeetrixIcon(.lock, size: .sm, variant: .filled)
                            Text("Two-step verification is on").qeetrixTextStyle(.body)
                        }
                        .foregroundStyle(QeetrixColor.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: QeetrixSpacing.xs) {
                    ForEach(QeetrixTextRole.allCases, id: \.self) { role in
                        Text(role.rawValue)
                            .qeetrixTextStyle(role)
                            .foregroundStyle(QeetrixColor.textPrimary)
                    }
                }

                HStack(spacing: QeetrixSpacing.m) {
                    ForEach([QeetrixIconName.bell, .mail, .settings, .search, .send], id: \.self) { name in
                        QeetrixIcon(name, label: Text(name.rawValue))
                            .foregroundStyle(QeetrixColor.actionPrimary)
                    }
                }

                HStack(spacing: QeetrixSpacing.s) {
                    QeetrixBadge("Active", variant: .success)
                    QeetrixBadge("Draft", variant: .secondary)
                    QeetrixBadge("Blocked", variant: .destructive)
                }
            }
            .padding(QeetrixSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Brand")
    }
}
