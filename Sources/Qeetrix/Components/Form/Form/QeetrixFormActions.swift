import SwiftUI

/// A form's action buttons — the web's `FormActions`.
///
/// ```swift
/// QeetrixFormActions {
///     QeetrixButton("Cancel", variant: .outline) { dismiss() }
///     QeetrixButton("Create account", isLoading: isSubmitting) { submit() }
/// }
/// ```
///
/// List the buttons in reading order, primary last. On a compact-width screen they stack full-width with
/// the primary on top, where a thumb reaches it first; in a regular-width size class they sit in a row at
/// the trailing edge, primary last. VoiceOver reads them in the order they appear.
public struct QeetrixFormActions<Content: View>: View {
    let content: Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        let isCompact = horizontalSizeClass == .compact
        QeetrixFormActionsLayout(isCompact: isCompact) {
            content
        }
        .environment(\.qeetrixButtonFillsWidth, isCompact)
        .padding(.top, QeetrixWebScale.spacing(2))  // pt-2
    }
}

/// `flex flex-col-reverse gap-2 sm:flex-row sm:flex-wrap sm:justify-end`: stacked in reverse on compact
/// width, a trailing row otherwise — wrapping, last first, when the row does not fit.
struct QeetrixFormActionsLayout: Layout {
    let isCompact: Bool
    var spacing: CGFloat = QeetrixWebScale.spacing(2)  // gap-2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for placement in arrange(width: bounds.width, subviews: subviews).placements {
            subviews[placement.index].place(
                at: CGPoint(x: bounds.minX + placement.frame.minX, y: bounds.minY + placement.frame.minY),
                proposal: ProposedViewSize(placement.frame.size))
        }
    }

    private struct Placement {
        let index: Int
        let frame: CGRect
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> (placements: [Placement], size: CGSize) {
        guard !subviews.isEmpty else { return ([], .zero) }
        if isCompact {
            // Last first, each the full width.
            var y: CGFloat = 0
            var placements: [Placement] = []
            for index in subviews.indices.reversed() {
                let size = subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil))
                placements.append(Placement(index: index, frame: CGRect(x: 0, y: y, width: width, height: size.height)))
                y += size.height + spacing
            }
            return (placements, CGSize(width: width, height: y - spacing))
        }
        // Rows from the trailing edge; when a row is full the earlier buttons wrap onto the next line.
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var rows: [[Int]] = [[]]
        var rowWidth: CGFloat = 0
        for index in subviews.indices.reversed() {
            let needed = sizes[index].width + (rows[rows.count - 1].isEmpty ? 0 : spacing)
            if !rows[rows.count - 1].isEmpty && rowWidth + needed > width {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].insert(index, at: 0)
            rowWidth += sizes[index].width + (rows[rows.count - 1].count > 1 ? spacing : 0)
        }
        var placements: [Placement] = []
        var y: CGFloat = 0
        var widest: CGFloat = 0
        for row in rows.reversed() {
            let rowWidth = row.map { sizes[$0].width }.reduce(0, +) + spacing * CGFloat(max(0, row.count - 1))
            let rowHeight = row.map { sizes[$0].height }.max() ?? 0
            var x = (width.isFinite ? width : rowWidth) - rowWidth
            for index in row {
                placements.append(Placement(index: index, frame: CGRect(x: x, y: y, width: sizes[index].width, height: rowHeight)))
                x += sizes[index].width + spacing
            }
            widest = max(widest, rowWidth)
            y += rowHeight + spacing
        }
        return (placements, CGSize(width: width.isFinite ? width : widest, height: y - spacing))
    }
}
