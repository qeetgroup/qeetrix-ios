import SwiftUI

/// Key numbers in a ruled strip — `@qeetrix/react`'s StatGroup: ``QeetrixStat``s side by side in equal
/// cells, at least 200 pt wide, with 1 pt `color.border.default` rules between them.
///
/// ```swift
/// QeetrixStatGroup {
///     QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"))
///     QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"))
/// }
/// ```
///
/// A strip W points wide has W ÷ 200 columns, as many as it has stats at most, and the cells of a row
/// share their height. Where the cells wrap — on a phone, one to a row — each row starts and ends on
/// the gutter, with no rule at its start, and a rule runs above it across the whole strip, past a short
/// last row, as stat.css draws it. Rows and rules follow the reading direction.
public struct QeetrixStatGroup<Content: View>: View {
    let content: Content

    /// - Parameter content: The stats.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        QeetrixStatGroupLayout {
            content
        }
        .environment(\.qeetrixStatIsInGroup, true)
        .foregroundStyle(QeetrixColor.textDefault)
        // `overflow: clip`: each cell starts 1 pt before its column and row, under its neighbour's edge,
        // so its rules — at its start and top, as stat.css draws them — fall outside the strip in the
        // first column and the first row.
        .clipped()
    }
}

/// The strip's grid (stat.css `.qx-stat-group`): `repeat(auto-fit, minmax(min(100%, 200px), 1fr))`.
struct QeetrixStatGroupLayout: Layout {
    /// `minmax(min(100%, 200px), 1fr)`.
    static let minimumCell: CGFloat = 200

    /// How many columns a strip `width` wide gives `count` cells: as many 200 pt cells as fit, at least
    /// one, never more than there are cells (`auto-fit` collapses the empty tracks).
    static func columns(width: CGFloat, count: Int) -> Int {
        guard count > 0 else { return 1 }
        return Swift.min(count, Swift.max(1, Int((width / minimumCell).rounded(.down))))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? CGFloat(subviews.count) * Self.minimumCell
        let rows = rowHeights(width: width, subviews: subviews)
        return CGSize(width: width, height: rows.reduce(0, +))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columns = Self.columns(width: bounds.width, count: subviews.count)
        let cell = bounds.width / CGFloat(columns)
        let rows = rowHeights(width: bounds.width, subviews: subviews)
        let rule = QeetrixBorderWidth.default
        var y = bounds.minY
        for (row, height) in rows.enumerated() {
            for column in 0..<columns {
                let index = row * columns + column
                guard index < subviews.count else { break }
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + CGFloat(column) * cell - rule, y: y - rule), anchor: .topLeading,
                    proposal: ProposedViewSize(width: cell + rule, height: height + rule))
            }
            y += height
        }
    }

    /// Each row's height: its tallest cell's.
    private func rowHeights(width: CGFloat, subviews: Subviews) -> [CGFloat] {
        let columns = Self.columns(width: width, count: subviews.count)
        let cell = width / CGFloat(columns)
        return stride(from: 0, to: subviews.count, by: columns).map { start in
            subviews[start..<Swift.min(start + columns, subviews.count)]
                .map {
                    $0.sizeThatFits(ProposedViewSize(width: cell + QeetrixBorderWidth.default, height: nil)).height
                        - QeetrixBorderWidth.default
                }
                .max() ?? 0
        }
    }
}

/// A grouped stat's rules, at its start and top as stat.css draws them: `border-inline-start` between
/// cells, and the wrapped rows' rule (`.qx-stat:before`, `inline-size: 100cqi`), which runs on past a
/// short last row to the strip's end. The strip clips them in the first column and the first row.
struct QeetrixStatRules: ViewModifier {
    /// Long enough to run past a short last row to the strip's end.
    static let rowRuleLength: CGFloat = 10_000

    func body(content: Content) -> some View {
        let width = QeetrixBorderWidth.default
        content
            // The content sits where stat.css puts it, inside the 1 pt border.
            .padding(.leading, width)
            .padding(.top, width)
            .overlay(alignment: .leading) {
                Rectangle().fill(QeetrixColor.borderDefault).frame(width: width).accessibilityHidden(true)
            }
            .overlay(alignment: .topLeading) {
                Rectangle().fill(QeetrixColor.borderDefault).frame(width: Self.rowRuleLength, height: width).accessibilityHidden(true)
            }
    }
}

private struct QeetrixStatIsInGroupKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether the stat sits in a ``QeetrixStatGroup``, which rules its cells.
    var qeetrixStatIsInGroup: Bool {
        get { self[QeetrixStatIsInGroupKey.self] }
        set { self[QeetrixStatIsInGroupKey.self] = newValue }
    }
}
