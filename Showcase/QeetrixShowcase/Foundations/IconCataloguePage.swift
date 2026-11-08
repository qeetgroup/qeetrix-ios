import Qeetrix
import QeetrixIconsExtended
import SwiftUI

/// Every `@qeetrix/icons` icon — the core set and `QeetrixIconsExtended` — searchable by name. A lazy grid, so only the
/// icons on screen are decoded and drawn.
struct IconCataloguePage: View {
    @State private var query = ""
    private let all = (QeetrixIconName.allCases + QeetrixIconName.extendedCases).sorted { $0.rawValue < $1.rawValue }

    private var shown: [QeetrixIconName] {
        let text = query.trimmingCharacters(in: .whitespaces).lowercased()
        return text.isEmpty ? all : all.filter { $0.rawValue.contains(text) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
                QeetrixText(
                    query.isEmpty ? "\(all.count) icons, sharp outline as on controls" : "\(shown.count) of \(all.count)",
                    size: .sm, tone: .subtle)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: QeetrixSpace.gapSm)], spacing: QeetrixSpace.gapMd) {
                    ForEach(shown, id: \.self) { icon in
                        VStack(spacing: QeetrixSpace.gapXs) {
                            QeetrixIcon(icon, size: .lg, shape: .sharp)
                                .foregroundStyle(QeetrixColor.iconDefault)
                            QeetrixText(icon.rawValue, size: .sm, tone: .subtle)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(icon.rawValue)
                    }
                }
            }
            .padding(QeetrixSpace.insetLg)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Icons")
        .searchable(text: $query, prompt: "Search \(all.count) icons")
    }
}

#Preview {
    NavigationStack { IconCataloguePage() }.qeetrixTheme(.light)
}
