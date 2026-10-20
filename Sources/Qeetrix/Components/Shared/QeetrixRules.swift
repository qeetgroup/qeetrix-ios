import SwiftUI

/// The frames of the items a ``View/qeetrixRules(_:)`` container rules between, in layout order.
struct QeetrixRuledItemsKey: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    /// Marks this view as one item of the enclosing `qeetrixRules(_:)` container.
    func qeetrixRuledItem() -> some View {
        anchorPreference(key: QeetrixRuledItemsKey.self, value: .bounds) { [$0] }
    }

    /// Draws a hairline across this view at the top edge of every marked item but the first — the web's
    /// `border-t … first:border-t-0` between siblings, which SwiftUI cannot express without knowing which
    /// child comes first. Items that share a top edge, as in a grid row, share one rule. The marks stop
    /// here, so an enclosing container rules only its own items.
    func qeetrixRules(_ color: QeetrixColor?) -> some View {
        overlayPreferenceValue(QeetrixRuledItemsKey.self) { anchors in
            if let color {
                GeometryReader { proxy in
                    let edges = QeetrixRuleEdges.between(anchors.map { proxy[$0].minY })
                    ForEach(edges, id: \.self) { y in
                        Rectangle()
                            .fill(color)
                            .frame(width: proxy.size.width, height: QeetrixStroke.hairline)
                            .position(x: proxy.size.width / 2, y: y)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .transformPreference(QeetrixRuledItemsKey.self) { $0 = [] }
    }
}

enum QeetrixRuleEdges {
    /// The distinct top edges after the first, in order: where rules go.
    static func between(_ tops: [CGFloat]) -> [CGFloat] {
        var seen: [CGFloat] = []
        for top in tops.map({ ($0 * 2).rounded() / 2 }) where !seen.contains(top) {
            seen.append(top)
        }
        return Array(seen.sorted().dropFirst())
    }
}
